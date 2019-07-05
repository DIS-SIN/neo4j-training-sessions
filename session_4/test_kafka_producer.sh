#!/bin/bash

if [ $# -lt 3 ]; then
  echo "Usage: ./test_kafka_producer.sh <topic> <name> <surname>"
  exit
fi

python3 producer.py $1 $2 $3
