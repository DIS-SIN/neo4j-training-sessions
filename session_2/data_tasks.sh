#!/bin/bash

# This script uses bc command-line calculator. 
# Mac OS X: it is shipped with the OS
#
# Linux: 
#   sudo apt install bc	#Debian/Ubuntu
#   sudo yum install bc	#RHEL/CentOS
#   sudo dnf install bc	#Fedora 22+
#
# Windows:
# http://gnuwin32.sourceforge.net/packages/bc.htm
#

if [ $# -lt 1 ]; then
    echo "Usage: ./data_tasks.sh COMMANDS"
    echo "  To create initial password, cleanup Kaggle data, and import the dataset:"
    echo "      ./data_tasks.sh COMMANDS"
    echo "  COMMAND: "
    echo "      p: create initial password"
    echo "      k: cleanup Kaggle data"
    echo "      i: import the dataset"
    echo "      b: backup the graph database"
    echo "      r: restore the graph database"
    echo "      c: clear the graph database"
    echo "  EXAMPLES:"
    echo "      ./data_tasks.sh p: set password only"
    echo "      ./data_tasks.sh k: clean up Kaggle data only"
    echo "      ./data_tasks.sh i: import the whole dataset"
    echo "      ./data_tasks.sh b: backup existing graph database"
    echo "      ./data_tasks.sh r: restore the graph database from a previous copy"
    echo "      ./data_tasks.sh pkib: run a p -> k -> i -> b pipeline (1ST TIME)"
    echo "      ./data_tasks.sh cib: run a c -> i -> b pipeline (CLEAR + IMPORT)"
    echo "      ./data_tasks.sh rib: run a r -> i -> b pipeline (RESTORE + IMPORT)"
    echo " NOTE: order of (optional) execution is p -> k -> c -> r -> i -> b"
    exit
fi

HTTP_HOST_PORT=localhost:7474
BOLT_HOST_PORT=localhost:7687
USER_NAME=neo4j
PASSWORD="##dis@da2019##"
CONTAINER_NAME=neo4j-algo-apoc_graph-database_1

res1=$(date +%s)
commands=$1
echo 'Executing: '$commands

if [[ $commands == *"p"* ]]; then
    printf "\nConfigure authentication for neo4j server ...\n"
    curl -X POST -H "Accept: application/json; charset=UTF-8" -H "Content-Type: application/json" -H "Authorization:bmVvNGo6bmVvNGo=" http://$HTTP_HOST_PORT/user/neo4j/password -d '{"password" : "##dis@da2019##"}}'
    printf "[Configure authentication for neo4j server] done.\n\n"
fi

if [[ $commands == *"k"* ]]; then
    ./cleanup_kaggle.sh
fi

if [[ $commands == *"c"* ]]; then
    ./database_clear.sh
fi

if [[ $commands == *"r"* ]]; then
    ./database_restore.sh
fi

echo 'Wait for Neo4j ...'
end="$((SECONDS+300))"
while true; do
    console_log=`(docker exec -i $CONTAINER_NAME /var/lib/neo4j/bin/cypher-shell -u $USER_NAME -p $PASSWORD -a bolt://$BOLT_HOST_PORT) < check_apoc.cql  | grep 3 | head -n 1`
    [[ $console_log = *"3.5"*  ]] && break
    [[ "${SECONDS}" -ge "${end}" ]] && exit 1
    sleep 1
done

if [[ $commands == *"i"* ]]; then
    printf "Creating initial schema ...\n"
    (docker exec -i $CONTAINER_NAME /var/lib/neo4j/bin/cypher-shell -u $USER_NAME -p $PASSWORD -a bolt://$BOLT_HOST_PORT) < data_schema.cql
    printf "Done.\n" 

    printf "Import BLS, O*NET, Kaggle datasets ...\n"
    (docker exec -i $CONTAINER_NAME /var/lib/neo4j/bin/cypher-shell -u $USER_NAME -p $PASSWORD -a bolt://$BOLT_HOST_PORT) < data_import.cql
    printf "Done.\n"

    printf "Import OSM geocoded data ...\n"
    (docker exec -i $CONTAINER_NAME /var/lib/neo4j/bin/cypher-shell -u $USER_NAME -p $PASSWORD -a bolt://$BOLT_HOST_PORT) < import_osm_codes.cql
    printf "Done.\n"

    ./graph_db_report.sh
fi

if [[ $commands == *"b"* ]]; then
    ./database_backup.sh
fi

res2=$(date +%s)
dt=$(echo "$res2 - $res1" | bc)
dd=$(echo "$dt/86400" | bc)
dt2=$(echo "$dt-86400*$dd" | bc)
dh=$(echo "$dt2/3600" | bc)
dt3=$(echo "$dt2-3600*$dh" | bc)
dm=$(echo "$dt3/60" | bc)
ds=$(echo "$dt3-60*$dm" | bc)

printf "\nDONE. Total processing time: %d:%02d:%02d:%02d\n" $dd $dh $dm $ds
