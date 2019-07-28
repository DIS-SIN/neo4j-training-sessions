#!/bin/bash

if [ $# -lt 1 ]; then
  echo "Usage: ./cleanup_docker.sh <docker-compose.yml file>"
  exit
fi

docker-compose -f $1 down
docker system prune
docker container rm -f $(docker container ls -aq)
docker image rm -f $(docker image ls -aq)
docker system info
