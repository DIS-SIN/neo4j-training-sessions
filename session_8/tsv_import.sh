#!/bin/bash

res1=$(date +%s)

export MSYS_NO_PATHCONV=1

BOLT_HOST_PORT=localhost:7687
USER_NAME=neo4j
PASSWORD="##dis@da2019##"
CONTAINER_NAME=jotunheimr

printf "Creating initial schema ...\n"
(docker exec -i $CONTAINER_NAME /var/lib/neo4j/bin/cypher-shell -u $USER_NAME -p $PASSWORD -a bolt://$BOLT_HOST_PORT) < import_scripts/data_schema.cql
printf "Done.\n"

printf "Import data ...\n"
(docker exec -i $CONTAINER_NAME /var/lib/neo4j/bin/cypher-shell -u $USER_NAME -p $PASSWORD -a bolt://$BOLT_HOST_PORT) < import_scripts/tsv_import.cql
printf "Done.\n"

printf "Convert data ...\n"
(docker exec -i $CONTAINER_NAME /var/lib/neo4j/bin/cypher-shell -u $USER_NAME -p $PASSWORD -a bolt://$BOLT_HOST_PORT) < import_scripts/data_convert_simple.cql
printf "Done.\n"

printf "Normalize data ...\n"
(docker exec -i $CONTAINER_NAME /var/lib/neo4j/bin/cypher-shell -u $USER_NAME -p $PASSWORD -a bolt://$BOLT_HOST_PORT) < import_scripts/data_normalization.cql
printf "Done.\n"

printf "Snapshot report ...\n"
(docker exec -i $CONTAINER_NAME /var/lib/neo4j/bin/cypher-shell -u $USER_NAME -p $PASSWORD -a bolt://$BOLT_HOST_PORT) < import_scripts/graph_db_report.cql
printf "Done.\n"

res2=$(date +%s)
diff=`echo $((res2-res1)) | awk '{printf "%02dh:%02dm:%02ds\n",int($1/3600),int($1%3600/60),int($1%60)}'`
printf "\n[Data import] DONE. Total processing time: %s.\n" $diff

export MSYS_NO_PATHCONV=0
