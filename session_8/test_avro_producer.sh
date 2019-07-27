#!/bin/bash

if [ $# -lt 2 ]; then
  echo "Usage: ./test_avro_producer.sh <topic> <schema>"
  echo "  ./test_avro_producer.sh avro-topic '{\"type\":\"record\",\"name\":\"User\",\"fields\":[{\"name\":\"name\",\"type\":\"string\"}, {\"name\":\"surname\",\"type\":\"string\"}]}'"
  exit
fi

echo "Press Ctrl+C when you want to stop the producer."

docker exec --interactive yggdrasil_schema_registry kafka-avro-console-producer \
  --broker-list yggdrasil_broker:9093 \
  --topic $1 \
  --property value.schema="$2"
