#!/bin/bash

# This script download:
# http://nlp.stanford.edu/software/stanford-corenlp-full-2018-10-05.zip
# http://nlp.stanford.edu/software/stanford-english-corenlp-2018-10-05-models.jar
# http://nlp.stanford.edu/software/stanford-english-kbp-corenlp-2018-10-05-models.jar
#
# and places:
# joda-time.jar, jollyday.jar, protobuf.jar
# stanford-corenlp-3.9.2.jar, stanford-corenlp-3.9.2-models.jar
# stanford-english-corenlp-2018-10-05-models.jar, stanford-english-kbp-corenlp-2018-10-05-models.jar
#
# into a `stanford_jars` directory for the `stanford-nlp-full` docker
#

res1=$(date +%s)

JAR_DEST=~/stanford_jars

echo '*.jar files will be placed into ' $JAR_DEST ' ...'

if [ ! -d $JAR_DEST ]; then
    mkdir $JAR_DEST
fi

STANFORD_NLP_RELEASE='2018-10-05'
STANFORD_NLP_PREFIX='stanford-corenlp-full'
STANFORD_NLP_VERSION='3.9.2'
STANFORD_NLP_URI='http://nlp.stanford.edu/software'

STANFORD_NLP=$STANFORD_NLP_PREFIX-$STANFORD_NLP_RELEASE

STANFORD_NLP_URL=$STANFORD_NLP_URI/$STANFORD_NLP

JODA_TIME=$STANFORD_NLP/joda-time.jar
JOLLYDAY=$STANFORD_NLP/jollyday.jar
PROTOBUF=$STANFORD_NLP/protobuf.jar
CORENLP=$STANFORD_NLP/stanford-corenlp-$STANFORD_NLP_VERSION.jar
CORENLP_MODELS=$STANFORD_NLP/stanford-corenlp-$STANFORD_NLP_VERSION-models.jar
XOM_JAR=$STANFORD_NLP/xom.jar
ENGLISH_MODELS=stanford-english-corenlp-$STANFORD_NLP_RELEASE-models.jar
ENGLISH_KBP_MODELS=stanford-english-kbp-corenlp-$STANFORD_NLP_RELEASE-models.jar

curl --fail --show-error --location --remote-name $STANFORD_NLP_URL.zip
unzip $STANFORD_NLP_URL.zip

curl --fail --show-error --location --remote-name $STANFORD_NLP_URI/$ENGLISH_MODELS
curl --fail --show-error --location --remote-name $STANFORD_NLP_URI/$ENGLISH_KBP_MODELS

mv -v $JODA_TIME $JAR_DEST/.
mv -v $JOLLYDAY $JAR_DEST/.
mv -v $PROTOBUF $JAR_DEST/.
mv -v $CORENLP $JAR_DEST/.
mv -v $CORENLP_MODELS $JAR_DEST/.
mv -v $XOM_JAR $JAR_DEST/.
mv -v $ENGLISH_MODELS $JAR_DEST/.
mv -v $ENGLISH_KBP_MODELS $JAR_DEST/.

rm -rf $STANFORD_NLP

res2=$(date +%s)
dt=$(echo "$res2 - $res1" | bc)
dd=$(echo "$dt/86400" | bc)
dt2=$(echo "$dt-86400*$dd" | bc)
dh=$(echo "$dt2/3600" | bc)
dt3=$(echo "$dt2-3600*$dh" | bc)
dm=$(echo "$dt3/60" | bc)
ds=$(echo "$dt3-60*$dm" | bc)

printf "\nDONE. Total processing time: %d:%02d:%02d:%02d\n" $dd $dh $dm $ds