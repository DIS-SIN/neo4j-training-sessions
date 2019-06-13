# -*- coding: utf-8 -*-
from os import getpid, kill
import signal
import traceback

from bs4 import BeautifulSoup
from bottle import BaseRequest, hook, request, response, route, run
from json import dumps, loads
import requests

from neo4j_adapter import Neo4jAdapter
from socket_adapter import SocketAdapter
from tag_chunker import TagChunker

BaseRequest.MEMFILE_MAX = 102400 * 1000

# Use 172.17.0.1 if runs inside Docker container
# Use localhost if runs outside of Docker
SCRAPPER_URI = 'http://172.17.0.1:8000/scrappe'
STANFORD_POS_HOST = '172.17.0.1'
STANFORD_POS_PORT = 8001
STANFORD_NER_HOST = '172.17.0.1'
STANFORD_NER_PORT = 8002

pos_adapter = SocketAdapter({
    'host': STANFORD_POS_HOST,
    'port': STANFORD_POS_PORT,
    'buffer_size': 4096,
    'wait_time': 3,
    'term_str': '\n\n',
    'loop': False
})

ner_adapter = SocketAdapter({
    'host': STANFORD_NER_HOST,
    'port': STANFORD_NER_PORT,
    'buffer_size': 4096,
    'wait_time': 3,
    'term_str': '\n\n',
    'loop': False
})

pos_chunker = TagChunker(
    {
        'I': lambda x: x.endswith('_NN') or x.endswith('_JJ'), # in-chunk tag
        'E': lambda x: x.endswith('_NN') or x.endswith('_NNS') or x.endswith('_VBG'), # chunk-end tag
    },
    lambda x: ' '.join(i[:i.rfind('_')] for i in x)
)

ner_chunker = TagChunker(
    {
        'B': lambda x: x[x.rfind('/')+1:].startswith('B-'), # start-chunk tag
        'I': lambda x: x[x.rfind('/')+1:].startswith('I-'), # in-chunk tag
    },
    lambda x: ' '.join(i[:i.rfind('/')] for i in x)
)

NEO4J_CONF = {
    'neo4j_bolt_server': 'bolt://172.17.0.1',
    'neo4j_user': 'neo4j',
    'neo4j_password': '##dis@da2019##',
}

neo4j_adapter = Neo4jAdapter(NEO4J_CONF)


def work_unit(tx, cypher=None):
    return tx.run(cypher)


def create_constraints_and_indexes():
    cyphers = [
        'CREATE CONSTRAINT ON (n:Movie) ASSERT n.url IS UNIQUE;',
        'CREATE INDEX ON :Movie(name, year);',
        'CREATE INDEX ON :Movie(rating);',
        'CREATE INDEX ON :Movie(story);',
        'CREATE INDEX ON :Movie(votes);',
        'CREATE CONSTRAINT ON (n:Genre) ASSERT n.text IS UNIQUE;',
        'CREATE CONSTRAINT ON (n:Director) ASSERT n.url IS UNIQUE;',
        'CREATE INDEX ON :Director(name);',
        'CREATE CONSTRAINT ON (n:Actor) ASSERT n.url IS UNIQUE;',
        'CREATE INDEX ON :Actor(name);',
        'CREATE CONSTRAINT ON (n:NamedEntity) ASSERT n.text IS UNIQUE;',
        'CREATE CONSTRAINT ON (n:KeyPhrase) ASSERT n.text IS UNIQUE;',
    ]
    neo4j_adapter.execute_sequential(
        [
            [work_unit, "WRITE_ACCESS", {'cypher': c}]
            for c in cyphers
        ], 
        need_result=False
    )


def list_constraints_and_indexes():
    result_text = []
    for cypher in ['CALL db.constraints;',  'CALL db.indexes;']:
        result = neo4j_adapter.execute_one(work_unit, mode="READ_ACCESS", need_result=True, cypher=cypher)
        result_text.extend([r['description'] for r in result])
    return '<br/>'.join(result_text)


CROSS_ORIGIN_RESOURCE_SHARING_HEADERS = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'PUT, GET, POST, DELETE, OPTIONS',
    'Access-Control-Allow-Headers':
        'Origin, Accept, Content-Type, X-Requested-With, X-CSRF-Token',
}

@hook('after_request')
def webapp_enable_cors():
    response.headers.update(CROSS_ORIGIN_RESOURCE_SHARING_HEADERS)


@route('/shutdown', method=['GET'])
def webapp_shutdown():
    kill(getpid(), signal.SIGINT)


@route('/', method='GET')
def webapp_info():
    return {'status': 'IMDB pipeline is running ...'}


@route('/prepare', method='GET')
def webapp_info():
    create_constraints_and_indexes()
    return list_constraints_and_indexes()


@route('/process', method='GET')
def process():

    movie_names = []
    try:
        # Harvest movie info by using imdb_scrapper container
        movie_info_list = loads(requests.get(SCRAPPER_URI).content)

        # For each movie description, run Stanford NLP
        for movie_info in movie_info_list:
            story = movie_info['story']

            # Extracting key-phrases
            pos_tagged_text = pos_adapter.tag(story)
            if pos_tagged_text:
                movie_info['story_pos'] = dict()
                for stack in pos_chunker.process(pos_tagged_text):
                    if stack not in movie_info['story_pos']:
                        movie_info['story_pos'][stack] = 0
                    movie_info['story_pos'][stack] += 1

            # Extracting named entities (location, organization, person)
            ner_tagged_text = ner_adapter.tag(story)
            if ner_tagged_text:
                movie_info['story_ner'] = dict()
                for stack in ner_chunker.process(ner_tagged_text):
                    if stack not in movie_info['story_ner']:
                        movie_info['story_ner'][stack] = 0
                    movie_info['story_ner'][stack] += 1

            movie_names.append(movie_info['name'])

        # create cyphers and using the python wrapper to persist them into the neo4j instance
        cypher = """
            MERGE (m:Movie {url: "%s"})
                SET m.name = "%s", m.year = '%s', m.rating = "%s", m.runtime = "%s", m.story = "%s", m.votes = "%s"
            WITH m
                FOREACH (e IN [%s] |
                    MERGE (g:Genre {text: e})
                    MERGE (m)-[:IN_GENRE]->(g)
                )
            WITH m
                FOREACH (p IN [%s] |
                    MERGE (d:Director {url: p[0]})
                        SET d.name = p[1]
                    MERGE (m)-[:DIRECTED_BY]->(d)
                )
            WITH m
                FOREACH (p IN [%s] |
                    MERGE (a:Actor {url: p[0]})
                        SET a.name = p[1]
                    MERGE (m)<-[:ACTED_IN]-(a)
                )
            WITH m
                FOREACH (p IN [%s] |
                    MERGE (ne:NamedEntity {text: p[0]})
                        ON CREATE SET ne.f = p[1]
                        ON MATCH SET ne.f = ne.f + p[1]
                    MERGE (m)-[:HAS_NE]->(ne)
                )
            WITH m
                FOREACH (p IN [%s] |
                    MERGE (kp:KeyPhrase {text: p[0]})
                        ON CREATE SET kp.f = p[1]
                        ON MATCH SET kp.f = kp.f + p[1]
                    MERGE (m)-[:HAS_KP]->(kp)
                )
            RETURN 1
        """

        cyphers = []
        for movie_info in movie_info_list:
            cyphers.append(
                cypher % (
                    movie_info['url'], movie_info['name'], movie_info['year'], 
                    movie_info['rating'], movie_info['runtime'], movie_info['story'], movie_info['votes'],
                    ', '.join('"%s"' % e for e in movie_info['genre']),
                    ', '.join('["%s", "%s"]' % (e['url'], e['name']) for e in movie_info['directors']),
                    ', '.join('["%s", "%s"]' % (e['url'], e['name']) for e in movie_info['actors']),
                    ', '.join('["%s", %d]' % (e, movie_info['story_ner'][e]) for e in movie_info['story_ner']) if 'story_ner' in movie_info else '',
                    ', '.join('["%s", %d]' % (e, movie_info['story_pos'][e]) for e in movie_info['story_pos']) if 'story_pos' in movie_info else '',
                )
            )

        neo4j_adapter.execute_sequential(
            [
                [work_unit, "WRITE_ACCESS", {'cypher': c}]
                for c in cyphers
            ], 
            need_result=False
        )

    except Exception:
        traceback.print_exc()
    
    return 'Imported: <br/><br/>' + '<br/>'.join(movie_names)


if __name__ == '__main__':

    try:
        run(
            host='0.0.0.0',
            port=8003,
            server='waitress',
            threads=4,
        )
    except KeyboardInterrupt:
        pass
