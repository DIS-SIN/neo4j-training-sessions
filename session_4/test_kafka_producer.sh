#!/bin/bash

if [ $# -lt 1 ]; then
  echo "Usage: ./test_kafka_producer.sh <topic>"
  exit
fi

echo "Press Ctrl+C when you want to stop the producer."

docker exec \
  --interactive \
  schema_registry \
  kafka-avro-console-producer \
  --broker-list broker:9093 \
  --topic $1 \
  --property value.schema='{"type":"record","name":"User","fields":[{"name":"name","type":"string"}, {"name":"surname","type":"string"}]}'
