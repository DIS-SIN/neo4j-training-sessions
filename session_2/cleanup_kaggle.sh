#!/bin/bash

NEO4J_ALGO_APOC=../../neo4j-algo-apoc

echo 'Removing quotations from users.tsv and user_history.tsv'
case "$(uname -s)" in
	Darwin)
        gsed -i 's/"//g' $NEO4J_ALGO_APOC/import/kaggle/job-recommendation/users.tsv
        gsed -i 's/"//g' $NEO4J_ALGO_APOC/import/kaggle/job-recommendation/user_history.tsv
        ;;

    *)
        sed -i 's/"//g' $NEO4J_ALGO_APOC/import/kaggle/job-recommendation/users.tsv
        sed -i 's/"//g' $NEO4J_ALGO_APOC/import/kaggle/job-recommendation/user_history.tsv
        ;;
esac

echo 'Removing description, requirements from jobs.tsv'

# If using Windows and Python is available:
# python simplify_jobs.py ../../neo4j-algo-apoc/import/kaggle/job-recommendation/jobs.tsv > ../../neo4j-algo-apoc/import/kaggle/job-recommendation/jobs_simplified.tsv
# On Linux or Mac OS X:
awk -F '\t' '{ printf("%s\t%s\t%s\t%s\t%s\n", $1, $3, $6, $7, $8, $9)}' $NEO4J_ALGO_APOC/import/kaggle/job-recommendation/jobs.tsv > $NEO4J_ALGO_APOC/import/kaggle/job-recommendation/jobs_simplified.tsv
wc -l $NEO4J_ALGO_APOC/import/kaggle/job-recommendation/jobs_simplified.tsv

echo 'Removing quotations from jobs_simplified.tsv'
case "$(uname -s)" in
	Darwin)
        gsed -i 's/"//g' $NEO4J_ALGO_APOC/import/kaggle/job-recommendation/jobs_simplified.tsv
        ;;

    *)
        sed -i 's/"//g' $NEO4J_ALGO_APOC/import/kaggle/job-recommendation/jobs_simplified.tsv
        ;;
esac