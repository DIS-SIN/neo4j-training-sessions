#!/bin/bash

 curl -X POST -H "Content-Type: application/vnd.kafka.avro.v2+json" \
  -H "Accept: application/vnd.kafka.v2+json" \
  --data '{"value_schema": "{\"type\": \"record\", \"name\": \"User\", \"fields\": [{\"name\": \"name\", \"type\": \"string\"}, {\"name\": \"surname\", \"type\": \"string\"}]}", "records": [{"value": {"name": "Viet", "surname": "Doan"}}]}' \
  http://localhost:8082/topics/my-topic
