#!/bin/bash

if [ $# -lt 1 ]; then
  echo "Usage: ./test_json_consumer.sh <topic>"
  echo "  ./test_json_consumer.sh json-topic"
  exit
fi

echo "Press Ctrl+C when you want to stop the consumer."

docker exec yggdrasil_broker kafka-console-consumer \
  --bootstrap-server yggdrasil_broker:9093 \
  --topic $1
