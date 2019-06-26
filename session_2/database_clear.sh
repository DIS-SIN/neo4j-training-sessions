#!/bin/bash

NEO4J_ALGO_APOC=../../neo4j-algo-apoc
TEMPORARY_DIRECTORY=../../
SESSION_2=$PWD

cd $NEO4J_ALGO_APOC \
    && source ./set_env.sh \
    && docker-compose down \
    && cd data \
    && sudo rm -rf databases \
    && cd .. \
    && docker-compose up -d \
    && cd $SESSION_2
