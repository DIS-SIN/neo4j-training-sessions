FROM openjdk:8-jre-alpine

# 3.9.2 - 2018-10-05
ENV STANFORD_NLP_RELEASE='2018-10-05' \
    STANFORD_NLP_VERSION='3.9.2'

RUN mkdir /stanford

COPY ~/stanford_jars/*.jar /stanford/

ENV CLASSPATH='joda-time.jar:jollyday.jar:protobuf.jar:stanford-corenlp-'${STANFORD_NLP_VERSION}'.jar:stanford-corenlp-'${STANFORD_NLP_VERSION}'-models.jar:stanford-english-corenlp-'${STANFORD_NLP_RELEASE}'-models.jar:stanford-english-kbp-corenlp-'${STANFORD_NLP_RELEASE}'-models.jar:xom.jar:*'

EXPOSE 80

WORKDIR /stanford

CMD java -Djava.net.preferIPv4Stack=true -Djava.io.tmpdir=/stanford -mx4g -cp $CLASSPATH -XX:+UseG1GC -XX:MaxGCPauseMillis=500 -XX:+UseStringDeduplication -XX:SoftRefLRUPolicyMSPerMB=100 edu.stanford.nlp.pipeline.StanfordCoreNLPServer -port 80
