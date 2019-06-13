FROM python:3.6-alpine

RUN apk add --no-cache bash bc \
    && pip3 install --upgrade pip \
    && pip3 install bottle waitress bs4 requests 

COPY imdb_scrapper/imdb_scrapper.py .
COPY imdb_scrapper/synopsis.tsv .

EXPOSE 8000

CMD python3 imdb_scrapper.py