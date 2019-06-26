#!/bin/bash

BOLT_HOST_PORT=localhost:7687
USER_NAME=neo4j
PASSWORD="##dis@da2019##"
CONTAINER_NAME=neo4j-algo-apoc_graph-database_1

printf "Snapshot report ...\n"
(docker exec -i $CONTAINER_NAME /var/lib/neo4j/bin/cypher-shell -u $USER_NAME -p $PASSWORD -a bolt://$BOLT_HOST_PORT) < graph_db_report.cql
printf "Done.\n"