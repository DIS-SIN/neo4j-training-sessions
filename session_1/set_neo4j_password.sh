#!/bin/bash

HTTP_HOST_PORT=localhost:7474

printf "\nConfigure authentication for neo4j server ...\n"
curl -X POST -H "Accept: application/json; charset=UTF-8" -H "Content-Type: application/json" -H "Authorization:bmVvNGo6bmVvNGo=" http://$HTTP_HOST_PORT/user/neo4j/password -d '{"password" : "##dis@da2019##"}}'
printf "[Configure authentication for neo4j server] done.\n\n"
