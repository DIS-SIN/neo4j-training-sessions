#!/bin/bash

PLUGINS=~/yggdrasil/connect/plugins/

docker-compose stop yggdrasil_connect

if [[ ! -d "$PLUGINS" ]]; then
  mkdir -p $PLUGINS
fi

if [[ ! -d "$PLUGINS/neo4j-kafka-connect-neo4j-1.0.3" ]]; then
  sudo chmod -R 777 $PLUGINS
  curl --fail --silent --show-error --location --remote-name "https://github.com/neo4j-contrib/neo4j-streams/releases/download/3.5.3/neo4j-kafka-connect-neo4j-1.0.3.zip"
  sudo rm -rf $PLUGINS/neo4j-kafka-connect-neo4j-1.0.3
  unzip neo4j-kafka-connect-neo4j-1.0.3.zip -d $PLUGINS
  sudo chmod -R 777 $PLUGINS
  rm neo4j-kafka-connect-neo4j-1.0.3.zip
fi
