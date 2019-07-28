#!/bin/bash

if [ $# -lt 1 ]; then
  echo "Usage: ./test_avro_producer.sh <topic>"
  echo "  ./test_avro_producer.sh json-topic"
  exit
fi

echo "Press Ctrl+C when you want to stop the producer."

docker exec --interactive yggdrasil_broker kafka-console-producer \
  --broker-list yggdrasil_broker:9093 \
  --topic $1
