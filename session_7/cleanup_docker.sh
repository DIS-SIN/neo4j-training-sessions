#!/bin/bash

source ./set_env.sh
docker-compose down
docker system prune
docker container rm -f $(docker container ls -aq)
docker image rm -f $(docker image ls -aq)
docker system info
