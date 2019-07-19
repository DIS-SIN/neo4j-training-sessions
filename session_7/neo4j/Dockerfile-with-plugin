FROM  neo4j:3.5.6

ENV ALGO_LIB_VERSION=3.5.4.0 \
    APOC_LIB_VERSION=3.5.0.4 \
    GRQL_LIB_VERSION=3.5.0.4 \
    GITHUB_ALGO_URI="https://github.com/neo4j-contrib/neo4j-graph-algorithms/releases/download" \
    GITHUB_APOC_URI="https://github.com/neo4j-contrib/neo4j-apoc-procedures/releases/download" \
    GITHUB_GRQL_URI="https://github.com/neo4j-graphql/neo4j-graphql/releases/download" \
    NEO4J_HOME="/var/lib/neo4j"

ENV NEO4J_ALGO_URI=${GITHUB_ALGO_URI}/${ALGO_LIB_VERSION}/graph-algorithms-algo-${ALGO_LIB_VERSION}.jar \
    NEO4J_APOC_URI=${GITHUB_APOC_URI}/${APOC_LIB_VERSION}/apoc-${APOC_LIB_VERSION}-all.jar \
    NEO4J_GRQL_URI=${GITHUB_GRQL_URI}/${GRQL_LIB_VERSION}/neo4j-graphql-${GRQL_LIB_VERSION}.jar

RUN curl --fail --silent --show-error --location ${NEO4J_ALGO_URI} --output "${NEO4J_HOME}"/plugins/graph-algorithms-algo-${ALGO_LIB_VERSION}.jar\
    && curl --fail --silent --show-error --location ${NEO4J_APOC_URI} --output "${NEO4J_HOME}"/plugins/apoc-${APOC_LIB_VERSION}-all.jar \
    && curl --fail --silent --show-error --location ${NEO4J_GRQL_URI} --output "${NEO4J_HOME}"/plugins/neo4j-graphql-${GRQL_LIB_VERSION}.jar
