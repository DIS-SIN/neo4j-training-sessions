FROM  neo4j:3.5.8

ENV ALGO_LIB_VERSION=3.5.4.0 \
    APOC_LIB_VERSION=3.5.0.4 \
    STREAMS_VERSION=3.5.3 \
    GRQL_LIB_VERSION=3.5.0.4 \
    GITHUB_ALGO_URI="https://github.com/neo4j-contrib/neo4j-graph-algorithms/releases/download" \
    GITHUB_APOC_URI="https://github.com/neo4j-contrib/neo4j-apoc-procedures/releases/download" \
    GITHUB_STREAMS_URI="https://github.com/neo4j-contrib/neo4j-streams/releases/download" \
    GITHUB_GRQL_URI="https://github.com/neo4j-graphql/neo4j-graphql/releases/download" \
    APACHE_MAVEN="http://repo1.maven.org/maven2/org/apache/" \
    APACHE_GITHUB="http://repo1.maven.org/maven2/com/github/" \
    APACHE_POI="poi-3.17.jar" \
    APACHE_POI_OOXML="poi-ooxml-3.17.jar" \
    APACHE_POI_OOXML_SCHEMAS="poi-ooxml-schemas-3.17.jar" \
    COMMON_COLLECTIONS="commons-collections4-4.1.jar" \
    CURVES_API="curvesapi-1.04.jar" \
    XML_BEANS="xmlbeans-2.6.0.jar" \
    NEO4J_HOME="/var/lib/neo4j"


ENV NEO4J_ALGO_URI=${GITHUB_ALGO_URI}/${ALGO_LIB_VERSION}/graph-algorithms-algo-${ALGO_LIB_VERSION}.jar \
    NEO4J_APOC_URI=${GITHUB_APOC_URI}/${APOC_LIB_VERSION}/apoc-${APOC_LIB_VERSION}-all.jar \
    NEO4J_STREAMS_URI=${GITHUB_STREAMS_URI}/${STREAMS_VERSION}/neo4j-streams-${STREAMS_VERSION}.jar \
    NEO4J_GRQL_URI=${GITHUB_GRQL_URI}/${GRQL_LIB_VERSION}/neo4j-graphql-${GRQL_LIB_VERSION}.jar \
    APACHE_POI_URI=${APACHE_MAVEN}poi/poi/3.17/${APACHE_POI} \
    APACHE_POI_OOXML_URI=${APACHE_MAVEN}poi/poi-ooxml/3.17/${APACHE_POI_OOXML} \
    APACHE_POI_OOXML_SCHEMAS_URI=${APACHE_MAVEN}poi/poi-ooxml-schemas/3.17/${APACHE_POI_OOXML_SCHEMAS} \
    COMMON_COLLECTIONS_URI=${APACHE_MAVEN}commons/commons-collections4/4.1/${COMMON_COLLECTIONS} \
    CURVES_API_URI=${APACHE_GITHUB}virtuald/curvesapi/1.04/${CURVES_API} \
    XML_BEANS_URI=${APACHE_MAVEN}xmlbeans/xmlbeans/2.6.0/${XML_BEANS}

RUN curl --fail --silent --show-error --location ${NEO4J_ALGO_URI} --output "${NEO4J_HOME}"/plugins/graph-algorithms-algo-${ALGO_LIB_VERSION}.jar\
    && curl --fail --silent --show-error --location ${NEO4J_APOC_URI} --output "${NEO4J_HOME}"/plugins/apoc-${APOC_LIB_VERSION}-all.jar \
    && curl --fail --silent --show-error --location ${NEO4J_STREAMS_URI} --output "${NEO4J_HOME}"/plugins/neo4j-streams-${STREAMS_VERSION}.jar \
    && curl --fail --silent --show-error --location ${NEO4J_GRQL_URI} --output "${NEO4J_HOME}"/plugins/neo4j-graphql-${GRQL_LIB_VERSION}.jar \
    && curl --fail --silent --show-error --location ${APACHE_POI_URI} --output "${NEO4J_HOME}"/plugins/${APACHE_POI} \
    && curl --fail --silent --show-error --location ${APACHE_POI_OOXML_URI} --output "${NEO4J_HOME}"/plugins/${APACHE_POI_OOXML} \
    && curl --fail --silent --show-error --location ${APACHE_POI_OOXML_SCHEMAS_URI} --output "${NEO4J_HOME}"/plugins/${APACHE_POI_OOXML_SCHEMAS} \
    && curl --fail --silent --show-error --location ${COMMON_COLLECTIONS_URI} --output "${NEO4J_HOME}"/plugins/${COMMON_COLLECTIONS} \
    && curl --fail --silent --show-error --location ${CURVES_API_URI} --output "${NEO4J_HOME}"/plugins/${CURVES_API} \
    && curl --fail --silent --show-error --location ${XML_BEANS_URI} --output "${NEO4J_HOME}"/plugins/${XML_BEANS} \
    && echo 'Done.'
