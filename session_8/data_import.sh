#!/bin/bash

if [ $# -lt 2 ]; then
  echo "Usage: ./data_import.sh <COMMANDS> <neo4j directory> "
  echo "  COMMAND: "
  echo "      n: normalize data"
  echo "      e: extract entities and relationships"
  echo "      i: import data"
  echo "      a: after import processing"
  echo "      s: export statistics"
  echo "  EXAMPLES:"
  echo "      ./data_import.sh n: normalize registration & survey data only"
  echo "      ./data_import.sh e: extract entities and relationships only"
  echo "      ./data_import.sh i: import data only"
  echo "      ./data_import.sh a: after import processing only"
  echo "      ./data_import.sh s: export statistics only"
  echo "      ./data_import.sh rneis: run a n -> e -> i -> a -> s pipeline"
  exit
fi

export MSYS_NO_PATHCONV=1

commands=$1
NEO4J_DIR=$2

if [[ ! -d "$NEO4J_DIR" ]]; then
  echo NEO4J_DIR=$NEO4J_DIR
  echo "No directory for neo4j found."
  export MSYS_NO_PATHCONV=0
  exit
fi

res1=$(date +%s)

if [[ ! -d "$NEO4J_DIR/data" ]]; then
  mkdir $NEO4J_DIR/data
  chmod -R 777 $NEO4J_DIR/data
fi

if [[ $commands == *"r"* ]]; then
  if [ ! -f "$NEO4J_DIR/import/csps/registration_data.tsv" ] || [ ! -f "$NEO4J_DIR/import/csps/survey_data.tsv" ] ; then
    echo "Required data files in $NEO4J_DIR/import/ directory: registration_data.tsv, survey_data.tsv"
    export MSYS_NO_PATHCONV=0
    exit
  fi
fi

if [[ $commands == *"n"* ]]; then
  printf "\nNormalize registration & survey data ...\n"
  ./import_scripts/header_normalizer.sh $NEO4J_DIR/import/csps/registration_data.tsv $NEO4J_DIR/import/csps/survey_data.tsv
  printf "Done.\n"
fi

if [[ $commands == *"e"* ]]; then
  printf "Extracting entities and relationships ...\n"
  unameOut="$(uname -s)"
  case "${unameOut}" in
    MINGW*)
      WIN_NEO4J_DIR=`echo $NEO4J_DIR |  sed 's~/c/~C:/~g'`
      echo WIN_NEO4J_DIR=$WIN_NEO4J_DIR
      python import_scripts/prepare_data.py $WIN_NEO4J_DIR/import/csps/registration_data.tsv $WIN_NEO4J_DIR/import/csps/survey_data.tsv
      ;;
    *)
      python import_scripts/prepare_data.py $NEO4J_DIR/import/csps/registration_data.tsv $NEO4J_DIR/import/csps/survey_data.tsv
      ;;
  esac
  printf "Done.\n"
fi

HTTP_HOST_PORT=localhost:7474
BOLT_HOST_PORT=localhost:7687
USER_NAME=neo4j
PASSWORD="##dis@da2019##"
CONTAINER_NAME=jotunheimr
CURRENT=$PWD

if [[ $commands == *"i"* ]]; then
  docker-compose stop $CONTAINER_NAME \
  && sudo rm -f $NEO4J_DIR/logs/import_report.log \
  && cd $NEO4J_DIR/data \
  && sudo rm -rf databases \
  && cd $CURRENT \
  && docker-compose up -d $CONTAINER_NAME

  ./import_scripts/wait_for_neo4j.sh $CONTAINER_NAME

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

  if [[ -f "$NEO4J_DIR/logs/import_report.log" ]]; then
    printf "Import issues:\n"
    cat $NEO4J_DIR/logs/import_report.log
  fi

  docker-compose stop $CONTAINER_NAME \
  && cd $NEO4J_DIR/data \
  && sudo rm -rf databases/graph.db \
  && sudo mv databases/csps_survey databases/graph.db \
  && sudo chmod -R 777 databases \
  && cd $CURRENT \
  && docker-compose up -d $CONTAINER_NAME

  ./import_scripts/wait_for_neo4j.sh $CONTAINER_NAME
fi

if [[ $commands == *"a"* ]]; then
  printf "Creating initial schema ...\n"
  (docker exec -i $CONTAINER_NAME /var/lib/neo4j/bin/cypher-shell -u $USER_NAME -p $PASSWORD -a bolt://$BOLT_HOST_PORT) < import_scripts/data_schema.cql
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
fi

if [[ $commands == *"s"* ]]; then
  if [[ ! -d "$NEO4J_DIR/import/csps/reports/" ]]; then
    printf "Create report directory ...\n"
    sudo mkdir $NEO4J_DIR/import/csps/reports
    printf "Grant access ...\n"
    sudo chmod 777 $NEO4J_DIR/import/csps/reports

    printf "Export statistics ...\n"
    (docker exec -i $CONTAINER_NAME /var/lib/neo4j/bin/cypher-shell -u $USER_NAME -p $PASSWORD -a bolt://$BOLT_HOST_PORT) < import_scripts/export_statistics.cql
    printf "Done.\n"
  fi
fi

res2=$(date +%s)
diff=`echo $((res2-res1)) | awk '{printf "%02dh:%02dm:%02ds\n",int($1/3600),int($1%3600/60),int($1%60)}'`
printf "\n[Data import] DONE. Total processing time: %s" $diff

export MSYS_NO_PATHCONV=0
