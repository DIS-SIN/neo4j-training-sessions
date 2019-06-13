FROM openjdk:8-jre-alpine

# 3.9.2 - 2018-10-16
ENV STANFORD_NLP_POS_VERSION='2018-10-16' \
    STANFORD_NLP_POS_URI='https://nlp.stanford.edu/software/stanford-postagger'

ENV STANFORD_NLP_POS=${STANFORD_NLP_POS_URI}-${STANFORD_NLP_POS_VERSION}.zip

RUN apk add --no-cache --quiet \
    curl \
    && curl --fail --silent --show-error --location --remote-name ${STANFORD_NLP_POS} \
    && mkdir /stanford \
    && unzip stanford-postagger-${STANFORD_NLP_POS_VERSION}.zip \
    && mv stanford-postagger-${STANFORD_NLP_POS_VERSION}/stanford-postagger.jar /stanford/. \
    && mv stanford-postagger-${STANFORD_NLP_POS_VERSION}/models/english-bidirectional-distsim.tagger /stanford/. \
    && mv stanford-postagger-${STANFORD_NLP_POS_VERSION}/models/english-bidirectional-distsim.tagger.props /stanford/. \
    && rm -rf stanford-postagger-${STANFORD_NLP_POS_VERSION}

EXPOSE 8001

WORKDIR /stanford

CMD java -mx500m -cp "stanford-postagger.jar:*" edu.stanford.nlp.tagger.maxent.MaxentTaggerServer --model "english-bidirectional-distsim.tagger" -port 8001
