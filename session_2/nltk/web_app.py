# -*- coding: utf-8 -*-
from os import getpid, kill
import signal
import traceback
import re

from bottle import BaseRequest, hook, request, response, route, run
from json import dumps, loads

from nltk.corpus import stopwords
from nltk.stem.snowball import EnglishStemmer
from nltk.stem.wordnet import WordNetLemmatizer

from socket_adapter import SocketAdapter
from tag_chunker import TagChunker

BaseRequest.MEMFILE_MAX = 102400 * 1000

REX_NORMALIZER=re.compile(r'-|\\|/', re.UNICODE)

STANFORD_POS_HOST = 'stanford-nlp-pos'
STANFORD_POS_PORT = 8001

pos_adapter = SocketAdapter({
    'host': STANFORD_POS_HOST,
    'port': STANFORD_POS_PORT,
    'buffer_size': 4096,
    'wait_time': 3,
    'term_str': '\n\n',
    'loop': False
})

pos_chunker = TagChunker(
    {
        'B': lambda x: x.endswith('_VBN'), # chunk-start tag
        'I': lambda x: x.endswith('_NN') or x.endswith('_JJ') or x.endswith('_VBN'), # in-chunk tag
        'E': lambda x: x.endswith('_NN') or x.endswith('_NNS') or x.endswith('_VBG') or x.endswith('_VBP'), # chunk-end tag
    },
    lambda x: ' '.join(i[:i.rfind('_')] for i in x)
)

en_lemmatizer = WordNetLemmatizer()
en_stemmer = EnglishStemmer()


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
    return {'status': 'NLTK web app is running ...'}


@route('/extract', method='POST')
def process():
    result_list = []
    try:
        text_requests = loads(request.body.read().decode('utf-8'))
        if not text_requests:
            return dumps({'ERR': 'No content specified.'})

        for text_request in text_requests:
            uid, text = text_request
            text = REX_NORMALIZER.sub(' ', text)
            key_phrase_list = pos_chunker.process(pos_adapter.tag(text.lower()))
            result_list.append([
                uid,
                [
                    [ 
                        en_stemmer.stem(en_lemmatizer.lemmatize(word)) 
                        for word in key_phrase.split() 
                    ]
                    for key_phrase in key_phrase_list
                ]
            ])

    except Exception:
        print(traceback.print_exc())
        return dumps(['%s' % traceback.print_exc()])
    
    return dumps(result_list)


if __name__ == '__main__':

    try:
        run(
            host='0.0.0.0',
            port=6543,
            server='waitress',
            threads=4,
        )
    except KeyboardInterrupt:
        pass
