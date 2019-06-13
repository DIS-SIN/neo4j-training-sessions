FROM python:3.6-alpine

RUN apk add --no-cache bash bc \
    && pip3 install --upgrade pip \
    && pip3 install bottle waitress bs4 requests neo4j-driver

COPY imdb_pipeline/*.py /

EXPOSE 8003

CMD python3 imdb_pipeline.py
