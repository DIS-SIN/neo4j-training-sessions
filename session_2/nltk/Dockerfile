FROM python:3.6-alpine

ENV NLTK_DATA=/nltk_data

RUN apk add --no-cache bash bc \
    && pip3 install --upgrade pip \
    && pip3 install bottle waitress nltk \
    && python3 -m nltk.downloader wordnet -d /nltk_data

RUN mkdir nlp

COPY nltk/*.py /nlp/

WORKDIR /nlp

EXPOSE 6543

CMD python3 web_app.py
