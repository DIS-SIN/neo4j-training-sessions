#!/bin/bash

if [ $# -lt 1 ]; then
  echo "Usage: ./test_avro_consumer.sh <topic>"
  echo "  ./test_avro_consumer.sh avro-topic"
  exit
fi

echo "Press Ctrl+C when you want to stop the consumer."

docker exec yggdrasil_schema_registry kafka-avro-console-consumer \
  --bootstrap-server yggdrasil_broker:9093 \
  --topic $1 \
