#!/bin/bash

if [ $# -lt 2 ]; then
  echo "Usage: ./data_tasks.sh <neo4j-algo-apoc directory> <COMMANDS>"
  echo "  COMMAND: "
  echo "      p: set initial password for neo4j"
  echo "      n: normalize registration & survey data"
  echo "      e: extract entities and relationships"
  echo "      i: import data"
  echo "      b: backup the graph database"
  echo "  EXAMPLES:"
  echo "      ./data_tasks.sh n: set initial password for neo4j only"
  echo "      ./data_tasks.sh n: normalize registration & survey data only"
  echo "      ./data_tasks.sh e: extract entities and relationships only"
  echo "      ./data_tasks.sh i: import data only"
  echo "      ./data_tasks.sh b: backup the graph database only"
  echo "      ./data_tasks.sh nepib: run a n -> e -> p -> i -> b pipeline (1ST TIME)"
  echo "      ./data_tasks.sh ib: run a i -> b pipeline (fresh IMPORT)"
  echo " NOTE: order of (optional) execution is n -> e -> i -> b"
  exit
fi

res1=$(date +%s)

commands=$2

if [[ $commands == *"n"* ]]; then
  if [ ! -f "$1/import/csps/registration_data.tsv" ] || [ ! -f "$1/import/csps/survey_data.tsv" ] ; then
    echo "Required data files in import/ directory of neo4j-algo-apoc: registration_data.tsv, survey_data.tsv"
  fi

  printf "\nNormalize registration & survey data ...\n"
  ./header_normalizer.sh $1/import/csps/registration_data.tsv $1/import/csps/survey_data.tsv
  printf "Done.\n"
fi

if [[ $commands == *"e"* ]]; then
  printf "Extracting entities and relationships ...\n"
  python prepare_data.py $1/import/csps/registration_data.tsv $1/import/csps/survey_data.tsv
  printf "Done.\n"
fi

HTTP_HOST_PORT=localhost:7474
BOLT_HOST_PORT=localhost:7687
USER_NAME=neo4j
PASSWORD="##dis@da2019##"
CONTAINER_NAME=neo4j-algo-apoc_graph-database_1
TEMPORARY_DIRECTORY=$1/..
CURRENT=$PWD

if [[ $commands == *"p"* ]]; then
  printf "\nConfigure authentication for neo4j server ...\n"
  curl -X POST -H "Accept: application/json; charset=UTF-8" -H "Content-Type: application/json" -H "Authorization:bmVvNGo6bmVvNGo=" http://$HTTP_HOST_PORT/user/neo4j/password -d '{"password" : "##dis@da2019##"}}'
  printf "[Configure authentication for neo4j server] done.\n\n"
fi

if [[ $commands == *"i"* ]]; then

  cd $1 \
    && source ./set_env.sh \
    && docker-compose down \
    && sudo rm -f logs/import_report.log \
    && cd data \
    && sudo rm -rf databases \
    && cd .. \
    && docker-compose up -d \
    && cd $CURRENT

  echo $PWD

  echo 'Wait for Neo4j ...'
  end="$((SECONDS+300))"
  while true; do
    console_log=`(docker exec -i $CONTAINER_NAME /var/lib/neo4j/bin/cypher-shell -u $USER_NAME -p $PASSWORD -a bolt://$BOLT_HOST_PORT) < check_apoc.cql  | grep 3 | head -n 1`
    [[ $console_log = *"3.5"*  ]] && break
    [[ "${SECONDS}" -ge "${end}" ]] && exit 1
    sleep 1
  done

  docker exec -i $CONTAINER_NAME /var/lib/neo4j/bin/neo4j-admin import \
      --database=csps_survey \
      --nodes:BusinessType /import/csps/business_type.tsv \
      --nodes:City /import/csps/city.tsv \
      --nodes:ClassificationGroup /import/csps/classification_group.tsv \
      --nodes:Classification /import/csps/classification.tsv \
      --nodes:Course /import/csps/course.tsv \
      --nodes:DeliveryType /import/csps/delivery_type.tsv \
      --nodes:Department /import/csps/department.tsv \
      --nodes:Instructor /import/csps/instructor.tsv \
      --nodes:Language /import/csps/language.tsv \
      --nodes:Learner /import/csps/learner.tsv \
      --nodes:Offering /import/csps/offering.tsv \
      --nodes:Province /import/csps/province.tsv \
      --nodes:Question /import/csps/question.tsv \
      --nodes:Region /import/csps/region.tsv \
      --nodes:Registration /import/csps/registration.tsv \
      --nodes:Survey /import/csps/survey.tsv \
      --relationships:BUSINESS_TYPE_OF /import/csps/business_type_TO_course.tsv \
      --relationships:LOCATED_IN /import/csps/city_TO_learner.tsv \
      --relationships:OFFERED_IN /import/csps/city_TO_offering.tsv \
      --relationships:CLASSIFICATION_GROUP_OF /import/csps/classification_group_TO_classification.tsv \
      --relationships:CLASSIFICATION_OF /import/csps/classification_TO_learner.tsv \
      --relationships:COURSE_OF /import/csps/course_TO_offering.tsv \
      --relationships:DELIVERY_TYPE_OF /import/csps/delivery_type_TO_course.tsv \
      --relationships:DEPARTMENT_OF /import/csps/department_TO_learner.tsv \
      --relationships:INSTRUCTOR_OF /import/csps/instructor_TO_offering.tsv \
      --relationships:LANGUAGE_OF /import/csps/language_TO_offering.tsv \
      --relationships:LEARNER_OF /import/csps/leaner_TO_registration.tsv \
      --relationships:REGISTERED_FOR /import/csps/offering_TO_registration.tsv \
      --relationships:SURVEYED_FOR /import/csps/offering_TO_survey.tsv \
      --relationships:PROVINCE_OF /import/csps/province_TO_city.tsv \
      --relationships:QUESTION_OF /import/csps/question_TO_survey.tsv \
      --relationships:REGION_OF /import/csps/region_TO_province.tsv \
      --delimiter TAB --array-delimiter "|" --multiline-fields true \
      --ignore-missing-nodes=true \
      --report-file=/logs/import_report.log \
      --quote '"'

  if [[ -f "$1/logs/import_report.log" ]]; then
    printf "Import issues:\n"
    cat $1/logs/import_report.log
  fi

  cd $1 \
    && source ./set_env.sh \
    && docker-compose down \
    && cd data \
    && sudo rm -rf databases/graph.db \
    && sudo mv databases/csps_survey databases/graph.db \
    && cd .. \
    && docker-compose up -d \
    && cd $CURRENT

  echo 'Wait for Neo4j ...'
  end="$((SECONDS+300))"
  while true; do
    console_log=`(docker exec -i $CONTAINER_NAME /var/lib/neo4j/bin/cypher-shell -u $USER_NAME -p $PASSWORD -a bolt://$BOLT_HOST_PORT) < check_apoc.cql  | grep 3 | head -n 1`
    [[ $console_log = *"3.5"*  ]] && break
    [[ "${SECONDS}" -ge "${end}" ]] && exit 1
    sleep 1
  done

  printf "Creating initial schema ...\n"
  (docker exec -i $CONTAINER_NAME /var/lib/neo4j/bin/cypher-shell -u $USER_NAME -p $PASSWORD -a bolt://$BOLT_HOST_PORT) < data_schema.cql
  printf "Done.\n"

  if [[ -d "$1/logs/import/csps/reports/" ]]; then
    printf "Create report directory ...\n"
    sudo mkdir $1/import/csps/reports
    printf "Grant access ...\n"
    sudo chmod 777 $1/import/csps/reports
  fi

  printf "Convert data ...\n"
  (docker exec -i $CONTAINER_NAME /var/lib/neo4j/bin/cypher-shell -u $USER_NAME -p $PASSWORD -a bolt://$BOLT_HOST_PORT) < data_convert.cql
  printf "Done.\n"

  printf "Export statistics ...\n"
  (docker exec -i $CONTAINER_NAME /var/lib/neo4j/bin/cypher-shell -u $USER_NAME -p $PASSWORD -a bolt://$BOLT_HOST_PORT) < export_statistics.cql
  printf "Done.\n"

fi

if [[ $commands == *"b"* ]]; then

  cd $1 \
    && source ./set_env.sh \
    && docker-compose down \
    && cd data \
    && tar czvf $TEMPORARY_DIRECTORY/csps_survey_gdb.tar.gz databases \
    && cd .. \
    && docker-compose up -d \
    && cd $CURRENT

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
