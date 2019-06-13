# -*- coding: utf-8 -*-

from os import getpid, kill
import signal
import traceback

from bs4 import BeautifulSoup
from bottle import BaseRequest, hook, request, response, route, run
import csv
from json import dumps
import requests

BaseRequest.MEMFILE_MAX = 102400 * 1000


def load_synopsis():
    movie_dict = dict()

    with open('synopsis.tsv') as tsv_file:
        reader = csv.DictReader(tsv_file, delimiter='\t')
        for row in reader:
            movie_dict['%s-%s' % (row['title'], row['year'])] = row['text'].replace('"','\'')

    return movie_dict


movie_synopsis_dict = load_synopsis()

IBDM_HOST = 'https://www.imdb.com'
IBDM_URL = IBDM_HOST + '/list/ls006405458/'

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
    return {'status': 'IMDB scapper is running ...'}


@route('/scrappe', method='GET')
def scrappe():

    movie_info_list = []
    try:
        text = requests.get(IBDM_URL).text
        soup = BeautifulSoup(text, 'html.parser')

        movie_list_tag = soup.find('div', {'class': 'lister-list'})
        movie_list = movie_list_tag.findAll('div', {'class': 'lister-item-content'})

        for movie in movie_list:

            header = movie.find('h3', {'class': 'lister-item-header'})

            movie_href_tag = header.findAll('a')[0]
            movie_year = movie.find('span', {'class': 'lister-item-year text-muted unbold'})
            movie_rating = movie.find('span', {'class': 'certificate'})
            movie_runtime = movie.find('span', {'class': 'runtime'})
            movie_genre = movie.find('span', {'class': 'genre'})
            movie_description = movie.find('p', {'class': ''}).text.strip()
            movie_votes = movie.find('span', {'name': 'nv'})

            movie_roles = movie.findAll('p', {'class': 'text-muted text-small'})[1]
            movie_roles_text = movie_roles.text.split('|')
            movie_role_hrefs = movie_roles.findAll('a')
            directors, actors = [], []
            for movie_role_href in movie_role_hrefs:
                if movie_role_href.text in movie_roles_text[0]:
                    directors.append({
                        'url': IBDM_HOST + movie_role_href['href'], 'name': movie_role_href.text
                    })
                if movie_role_href.text in movie_roles_text[1]:
                    actors.append({
                        'url': IBDM_HOST + movie_role_href['href'], 'name': movie_role_href.text
                    })

            movie_name = movie_href_tag.text.strip()
            movie_year = movie_year.text[1:-1] if movie_year.text else ''
            movie_key = '%s-%s' % (movie_name, movie_year)
            print(movie_key)
            if movie_key in movie_synopsis_dict:
                movie_description += movie_synopsis_dict[movie_key]

            movie_info = {
                'name':         movie_name,
                'url':          IBDM_HOST + movie_href_tag['href'],
                'year':         movie_year,
                'rating':       movie_rating.text if movie_rating else '',
                'runtime':      movie_runtime.text if movie_runtime else '',
                'genre':        [t.strip() for t in movie_genre.text.split(',')] if movie_genre else [],
                'story':        movie_description,
                'votes':        movie_votes['data-value'] if movie_votes else '',
                'directors':    directors,
                'actors':       actors
            }

            movie_info_list.append(movie_info)

    except Exception:
        traceback.print_exc()
    
    return dumps(movie_info_list)


if __name__ == '__main__':

    try:
        run(
            host='0.0.0.0',
            port=8000,
            server='waitress',
            threads=4,
        )
    except KeyboardInterrupt:
        pass

    # movie_info_list = scrappe()
    # for movie_info in movie_info_list:
    #     print(movie_info)

