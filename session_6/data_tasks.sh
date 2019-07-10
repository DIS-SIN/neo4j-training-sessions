#!/bin/bash

if [ $# -lt 1 ]; then
  echo "Usage: ./data_tasks.sh <COMMANDS>"
  echo "  COMMAND: "
  echo "      s: initialize with registration/survey data"
  echo "      r: restore the graph database"
  echo "      n: normalizing initial data"
  echo "      d: perform data discovery tasks"
  echo "      b: backup the graph database"
  echo "  EXAMPLES:"
  echo "      ./data_tasks.sh s: initialize with registration/survey data"
  echo "      ./data_tasks.sh r: restore the graph database from a previous copy"
  echo "      ./data_tasks.sh n: normalizing initial data"
  echo "      ./data_tasks.sh d: perform data discovery tasks"
  echo "      ./data_tasks.sh b: backup the graph database only"
  echo " NOTE: order of (optional) execution is s -> n -> d -> b"
  exit
fi

res1=$(date +%s)

commands=$1

HTTP_HOST_PORT=localhost:7474
BOLT_HOST_PORT=localhost:7687
USER_NAME=neo4j
PASSWORD="##dis@da2019##"
CONTAINER_NAME=neo4j
BACKUP_DIRECTORY=../../../..
CURRENT=$PWD

if [[ $commands == *"s"* ]]; then
  printf "Initializing in progress ...\n"

  docker-compose down \
  && cd neo4j/data \
  && sudo rm -rf databases \
  && sudo tar xzvf $BACKUP_DIRECTORY/csps_survey_gdb.tar.gz \
  && sudo chmod -R 777 databases \
  && cd ../.. \
  && docker-compose up -d

  echo 'Wait for Neo4j ...'
  end="$((SECONDS+300))"
  while true; do
    console_log=`(docker exec -i $CONTAINER_NAME /var/lib/neo4j/bin/cypher-shell -u $USER_NAME -p $PASSWORD -a bolt://$BOLT_HOST_PORT) < check_apoc.cql  | grep 3 | head -n 1`
    [[ $console_log = *"3.5"*  ]] && break
    [[ "${SECONDS}" -ge "${end}" ]] && exit 1
    sleep 1
  done

  printf "Done.\n"
fi

if [[ $commands == *"r"* ]]; then
  printf "Restoring in progress ...\n"

  docker-compose down \
  && cd neo4j/data \
  && sudo rm -rf databases \
  && sudo tar xzvf $BACKUP_DIRECTORY/session_6_gdb.tar.gz \
  && sudo chmod -R 777 databases \
  && cd ../.. \
  && docker-compose up -d

  echo 'Wait for Neo4j ...'
  end="$((SECONDS+300))"
  while true; do
    console_log=`(docker exec -i $CONTAINER_NAME /var/lib/neo4j/bin/cypher-shell -u $USER_NAME -p $PASSWORD -a bolt://$BOLT_HOST_PORT) < check_apoc.cql  | grep 3 | head -n 1`
    [[ $console_log = *"3.5"*  ]] && break
    [[ "${SECONDS}" -ge "${end}" ]] && exit 1
    sleep 1
  done

  printf "Done.\n"
fi

if [[ $commands == *"n"* ]]; then
  printf "Normalizing in progress...\n"
  (docker exec -i $CONTAINER_NAME /var/lib/neo4j/bin/cypher-shell -u $USER_NAME -p $PASSWORD -a bolt://$BOLT_HOST_PORT) < data_normalization.cql
  printf "Done.\n"
fi

if [[ $commands == *"d"* ]]; then
  printf "Discovery in progress...\n"

  echo 'Wait for Neo4j ...'
  end="$((SECONDS+300))"
  while true; do
    console_log=`(docker exec -i $CONTAINER_NAME /var/lib/neo4j/bin/cypher-shell -u $USER_NAME -p $PASSWORD -a bolt://$BOLT_HOST_PORT) < check_apoc.cql  | grep 3 | head -n 1`
    [[ $console_log = *"3.5"*  ]] && break
    [[ "${SECONDS}" -ge "${end}" ]] && exit 1
    sleep 1
  done

  printf "Snapshot report ...\n"
  (docker exec -i $CONTAINER_NAME /var/lib/neo4j/bin/cypher-shell -u $USER_NAME -p $PASSWORD -a bolt://$BOLT_HOST_PORT) < graph_db_report.cql
  printf "Done.\n"
fi

if [[ $commands == *"b"* ]]; then
  printf "Backup in progress...\n"

  docker-compose down \
  && cd neo4j/data \
  && tar czvf $BACKUP_DIRECTORY/session_6_gdb.tar.gz databases \
  && cd ../.. \
  && docker-compose up -d \

  echo 'Wait for Neo4j ...'
  end="$((SECONDS+300))"
  while true; do
    console_log=`(docker exec -i $CONTAINER_NAME /var/lib/neo4j/bin/cypher-shell -u $USER_NAME -p $PASSWORD -a bolt://$BOLT_HOST_PORT) < check_apoc.cql  | grep 3 | head -n 1`
    [[ $console_log = *"3.5"*  ]] && break
    [[ "${SECONDS}" -ge "${end}" ]] && exit 1
    sleep 1
  done

  printf "Snapshot report ...\n"
  (docker exec -i $CONTAINER_NAME /var/lib/neo4j/bin/cypher-shell -u $USER_NAME -p $PASSWORD -a bolt://$BOLT_HOST_PORT) < graph_db_report.cql
  printf "Done.\n"
fi

res2=$(date +%s)
dt=$(echo "$res2 - $res1" | bc)
dd=$(echo "$dt/86400" | bc)
dt2=$(echo "$dt-86400*$dd" | bc)
dh=$(echo "$dt2/3600" | bc)
dt3=$(echo "$dt2-3600*$dh" | bc)
dm=$(echo "$dt3/60" | bc)
ds=$(echo "$dt3-60*$dm" | bc)

printf "\n[Data import] DONE. Total processing time: %d:%02d:%02d:%02d\n" $dd $dh $dm $ds
