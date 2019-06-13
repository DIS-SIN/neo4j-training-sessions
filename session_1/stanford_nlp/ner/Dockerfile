FROM openjdk:8-jre-alpine

# 3.9.2 - 2018-10-16
ENV STANFORD_NLP_NER_VERSION='2018-10-16' \
    STANFORD_NLP_URI='https://nlp.stanford.edu/software/'

ENV STANFORD_NLP_NER_URI=${STANFORD_NLP_URI}stanford-ner

ENV STANFORD_NLP_NER=${STANFORD_NLP_NER_URI}-${STANFORD_NLP_NER_VERSION}.zip

RUN apk add --no-cache --quiet \
    curl \
    && curl --fail --silent --show-error --location --remote-name ${STANFORD_NLP_NER} \
    && curl --fail --silent --show-error --location --remote-name ${STANFORD_NLP_URI}conll.distsim.iob2.crf.ser.gz \
    && mkdir /stanford \
    && unzip stanford-ner-${STANFORD_NLP_NER_VERSION}.zip \
    && mv stanford-ner-${STANFORD_NLP_NER_VERSION}/stanford-ner.jar /stanford/. \
    && mv stanford-ner-${STANFORD_NLP_NER_VERSION}/lib/stanford-ner-resources.jar /stanford/. \
    && mv stanford-ner-${STANFORD_NLP_NER_VERSION}/lib/jollyday-0.4.9.jar /stanford/. \
    && mv stanford-ner-${STANFORD_NLP_NER_VERSION}/lib/joda-time.jar /stanford/. \
    && mv conll.distsim.iob2.crf.ser.gz /stanford/. \
   && rm -rf stanford-ner-${STANFORD_NLP_NER_VERSION}

EXPOSE 8002

WORKDIR /stanford

CMD java -mx1000m -cp "stanford-ner.jar:*" edu.stanford.nlp.ie.NERServer -loadClassifier "conll.distsim.iob2.crf.ser.gz" -port 8002
