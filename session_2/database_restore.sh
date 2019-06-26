#!/bin/bash

NEO4J_ALGO_APOC=../../neo4j-algo-apoc
TEMPORARY_DIRECTORY=../../
SESSION_2=$PWD

cd $NEO4J_ALGO_APOC \
    && source ./set_env.sh \
    && docker-compose down \
    && cd data \
    && sudo rm -rf databases \
    && sudo tar xzvf $TEMPORARY_DIRECTORY/session_2_gdb.tar.gz \
    && cd .. \
    && docker-compose up -d \
    && cd $SESSION_2
