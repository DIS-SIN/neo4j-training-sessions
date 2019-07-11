FROM  neo4j:3.5.6-enterprise

ENV ALGO_LIB_VERSION=3.5.4.0 \
    APOC_LIB_VERSION=3.5.0.4 \
    STREAMS_VERSION=3.5.3 \
    GITHUB_ALGO_URI="https://github.com/neo4j-contrib/neo4j-graph-algorithms/releases/download" \
    GITHUB_APOC_URI="https://github.com/neo4j-contrib/neo4j-apoc-procedures/releases/download" \
    GITHUB_STREAMS_URI="https://github.com/neo4j-contrib/neo4j-streams/releases/download" \
    NEO4J_HOME="/var/lib/neo4j"

ENV NEO4J_ALGO_URI=${GITHUB_ALGO_URI}/${ALGO_LIB_VERSION}/graph-algorithms-algo-${ALGO_LIB_VERSION}.jar \
    NEO4J_APOC_URI=${GITHUB_APOC_URI}/${APOC_LIB_VERSION}/apoc-${APOC_LIB_VERSION}-all.jar \
    NEO4J_STREAMS_URI=${GITHUB_STREAMS_URI}/${STREAMS_VERSION}/neo4j-streams-${STREAMS_VERSION}.jar

RUN curl --fail --silent --show-error --location --remote-name ${NEO4J_ALGO_URI} \
    && mv graph-algorithms-algo-${ALGO_LIB_VERSION}.jar "${NEO4J_HOME}"/plugins/. \
    && curl --fail --silent --show-error --location --remote-name ${NEO4J_APOC_URI} \
    && mv apoc-${APOC_LIB_VERSION}-all.jar "${NEO4J_HOME}"/plugins/. \
    && curl --fail --silent --show-error --location --remote-name ${NEO4J_STREAMS_URI} \
    && mv neo4j-streams-${STREAMS_VERSION}.jar "${NEO4J_HOME}"/plugins/.
