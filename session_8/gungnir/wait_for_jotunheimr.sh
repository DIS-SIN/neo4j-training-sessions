#!/bin/bash

host="$1"
shift
cmd="$@"

BOLT_HOST_PORT=$host:7687
USER_NAME=neo4j
PASSWORD="##dis@da2019##"
CONTAINER_NAME=$host

echo 'Wait for '$host' ...'
end="$((SECONDS+300))"
while true; do
  console_log=`nc -z $host 7474`
  echo $console_log
  [[ $console_log = *"open"*  ]] && break
  [[ "${SECONDS}" -ge "${end}" ]] && exit 1
  sleep 1
done

echo "Done."

exec $cmd
