#!/bin/bash

PLUGINS=~/yggdrasil/connect/plugins/

mkdir -p $PLUGINS
curl --fail --silent --show-error --location --remote-name "https://github.com/neo4j-contrib/neo4j-streams/releases/download/3.5.3/neo4j-kafka-connect-neo4j-1.0.3.zip"
unzip neo4j-kafka-connect-neo4j-1.0.3.zip -d $PLUGINS/
chmod -R 777 $PLUGINS
rm neo4j-kafka-connect-neo4j-1.0.3.zip
