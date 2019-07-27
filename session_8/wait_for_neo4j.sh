#!/bin/bash

BOLT_HOST_PORT=$1:7687
USER_NAME=neo4j
PASSWORD="##dis@da2019##"
CONTAINER_NAME=$1

echo 'Wait for Neo4j ...'
end="$((SECONDS+300))"
while true; do
  console_log=`echo "RETURN apoc.version();" | docker exec -i $CONTAINER_NAME /var/lib/neo4j/bin/cypher-shell -u $USER_NAME -p $PASSWORD -a bolt://$BOLT_HOST_PORT | grep 3 | head -n 1`
  [[ $console_log = *"3.5"*  ]] && break
  [[ "${SECONDS}" -ge "${end}" ]] && exit 1
  sleep 1
done
