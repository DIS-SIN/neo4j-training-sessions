#!/bin/bash

if [ $# -lt 1 ]; then
  echo "Usage: ./data_tasks.sh <COMMANDS>"
  echo "  COMMAND: "
  echo "      n: normalize registration & survey data"
  echo "      e: extract entities and relationships"
  echo "      i: import data"
  echo "      b: backup the graph database"
  echo "  EXAMPLES:"
  echo "      ./data_tasks.sh n: normalize registration & survey data only"
  echo "      ./data_tasks.sh e: extract entities and relationships only"
  echo "      ./data_tasks.sh i: import data only"
  echo "      ./data_tasks.sh b: backup the graph database only"
  echo "      ./data_tasks.sh neib: run a n -> e -> i -> b pipeline (1ST TIME)"
  echo "      ./data_tasks.sh ib: run a i -> b pipeline (fresh IMPORT)"
  echo " NOTE: order of (optional) execution is n -> e -> i -> b"
  exit
fi

res1=$(date +%s)

commands=$1

if [[ ! -d "neo4j/data" ]]; then
  mkdir neo4j/data
  chmod -R 777 neo4j/data
fi

if [[ $commands == *"n"* ]]; then
  if [ ! -f "neo4j/import/csps/registration_data.tsv" ] || [ ! -f "neo4j/import/csps/survey_data.tsv" ] ; then
    echo "Required data files in import/ directory of neo4j-algo-apoc: registration_data.tsv, survey_data.tsv"
  fi

  printf "\nNormalize registration & survey data ...\n"
  ./header_normalizer.sh neo4j/import/csps/registration_data.tsv neo4j/import/csps/survey_data.tsv
  printf "Done.\n"
fi

if [[ $commands == *"e"* ]]; then
  printf "Extracting entities and relationships ...\n"
  python prepare_data.py neo4j/import/csps/registration_data.tsv neo4j/import/csps/survey_data.tsv
  printf "Done.\n"
fi

HTTP_HOST_PORT=localhost:7474
BOLT_HOST_PORT=localhost:7687
USER_NAME=neo4j
PASSWORD="##dis@da2019##"
CONTAINER_NAME=neo4j-session-7
TEMPORARY_DIRECTORY=../../../..
CURRENT=$PWD

if [[ $commands == *"i"* ]]; then

  source ./set_env.sh \
    && docker-compose -f docker-compose.yml.with-plugin down \
    && sudo rm -f neo4j/logs/import_report.log \
    && cd neo4j/data \
    && sudo rm -rf databases \
    && cd $CURRENT \
    && docker-compose -f docker-compose.yml.with-plugin up -d

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

  if [[ -f "neo4j/logs/import_report.log" ]]; then
    printf "Import issues:\n"
    cat neo4j/logs/import_report.log
  fi

  source ./set_env.sh \
    && docker-compose -f docker-compose.yml.with-plugin down \
    && cd neo4j/data \
    && sudo rm -rf databases/graph.db \
    && sudo mv databases/csps_survey databases/graph.db \
    && sudo chmod -R 777 databases \
    && cd $CURRENT \
    && docker-compose -f docker-compose.yml.with-plugin up -d

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

  if [[ ! -d "neo4j/import/csps/reports/" ]]; then
    printf "Create report directory ...\n"
    sudo mkdir neo4j/import/csps/reports
    printf "Grant access ...\n"
    sudo chmod 777 neo4j/import/csps/reports
  fi

  printf "Convert data ...\n"
  (docker exec -i $CONTAINER_NAME /var/lib/neo4j/bin/cypher-shell -u $USER_NAME -p $PASSWORD -a bolt://$BOLT_HOST_PORT) < data_convert_simple.cql
  printf "Done.\n"

  printf "Normalize data ...\n"
  (docker exec -i $CONTAINER_NAME /var/lib/neo4j/bin/cypher-shell -u $USER_NAME -p $PASSWORD -a bolt://$BOLT_HOST_PORT) < data_normalization.cql
  printf "Done.\n"

  printf "Export statistics ...\n"
  (docker exec -i $CONTAINER_NAME /var/lib/neo4j/bin/cypher-shell -u $USER_NAME -p $PASSWORD -a bolt://$BOLT_HOST_PORT) < export_statistics.cql
  printf "Done.\n"

fi

if [[ $commands == *"b"* ]]; then

  source ./set_env.sh \
    && docker-compose -f docker-compose.yml.with-plugin down \
    && cd neo4j/data \
    && tar czvf $TEMPORARY_DIRECTORY/csps_survey_gdb.tar.gz databases \
    && cd $CURRENT \
    && docker-compose -f docker-compose.yml.with-plugin up -d

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
