#!/bin/bash

if [ $# -lt 1 ]; then
  echo "Usage: ./test_kafka_consumer.sh <topic>"
  exit
fi

echo "Press Ctrl+C when you want to stop the consumer."

python3 consumer.py $1
