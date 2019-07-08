#!/bin/bash

if [ $# -lt 1 ]; then
  echo "Usage: ./test_kafka_consumer.sh <topic>"
  exit
fi

echo "Press Ctrl+C when you want to stop the consumer."

docker exec schema_registry kafka-avro-console-consumer \
  --bootstrap-server broker:9093 \
  --topic $1 \
