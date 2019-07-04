#!/bin/bash

mkdir plugins
curl --fail --silent --show-error --location --remote-name "https://github.com/neo4j-contrib/neo4j-streams/releases/download/3.5.3/neo4j-kafka-connect-neo4j-1.0.3.zip"
mv neo4j-kafka-connect-neo4j-1.0.3.zip plugins/.
cd plugins
unzip neo4j-kafka-connect-neo4j-1.0.3.zip
cd ..
chmod 777 plugins
rm plugins/neo4j-kafka-connect-neo4j-1.0.3.zip
