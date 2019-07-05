# Neo4j streaming with Kafka

## A powerful framework for modern data streaming

[Apache Kafka](https://kafka.apache.org) provided by [Confluent Platform](https://www.confluent.io/product/confluent-platform/), together with [Neo4j](https://neo4j.com) as foundation for data streaming architecture.

## How to use this repository?

### Setting up the environment:

1. Setup environment variables:

        ./set_env.sh

2. Get `Kafka Connect Neo4j Sink` from `Confluent`:

        ./get_kafka_plugin.sh

    The script downloads `neo4j-kafka-connect-neo4j-1.0.3.zip` from [neo4j-streams-3.5.3](https://github.com/neo4j-contrib/neo4j-streams/releases/download/3.5.3/) and expands it in `plugins` sub-directory.

    For more information: [Kafka Connect Neo4j Sink](https://www.confluent.io/connector/kafka-connect-neo4j-sink/)

3. (Optional) Get a compressed copy of [registration/survey Neo4j database](https://drive.google.com/open?id=1r4mc6piO86ELTtRFZP-c8a5qpac4LTU3) to, for example, local `Downloads` directory.

        mkdir dwh/data
        mv ~/Download/csps_survey_gdb.tar.gz dwh/data/.
        cd dwh/data/
        tar xzvf csps_survey_gdb.tar.gz
        sudo chmod -R 777 databases

        (you might need to type your password here)

        rm csps_survey_gdb.tar.gz
        cd ../..

        (you should be in neo4j-training-sessions/session_4)

4. Build the dockers. Note that to build and run the whole set of dockers described in `docker-compose.yml`, you should have at least 8GB free memory. If you don't, find instructions below how you can build partial set of them and still test most of the scenarios.

        docker-compose up

  Note 1: *to create a fresh build with latest images (wherever possible)*

        docker-compose up --build

  Note 2: on slow network, slow machine, the whole build and startup process might takes 10-15 minutes.

  Note 3: during the build, when encounter errors, if you want to remove all containers, images, cleanup the system, use the following. Note that it would erase all containers and images, thus the build takes more time, so use it with caution.

        docker container rm -f $(docker container ls -aq)
        docker image rm -f $(docker image ls -aq)
        docker system prune

5. Rename `contrib.sink.avro.neo4j.json.txt`

        mv contrib.sink.avro.neo4j.json.template contrib.sink.avro.neo4j.json

6. Configure the `Neo4jSinkConnector` with `connect`:

      curl -X POST http://localhost:8083/connectors \
        -H 'Content-Type:application/json' \
        -H 'Accept:application/json' \
        -d @contrib.sink.avro.neo4j.json

        {  
          "name":"Neo4jSinkConnector",
          "config":{  
              "topics":"my-topic",
              "connector.class":"streams.kafka.connect.sink.Neo4jSinkConnector",
              "errors.retry.timeout":"-1",
              "errors.retry.delay.max.ms":"1000",
              "errors.tolerance":"all",
              "errors.log.enable":"true",
              "errors.log.include.messages":"true",
              "neo4j.server.uri":"bolt://neo4j:7687",
              "neo4j.authentication.basic.username":"neo4j",
              "neo4j.authentication.basic.password":"##dis@da2019##",
              "neo4j.encryption.enabled":"false",
              "neo4j.topic.cypher.my-topic":"MERGE (p:Person{name: event.name, surname: event.surname}) MERGE (f:Family{name: event.surname}) MERGE (p)-[:BELONGS_TO]->(f)",
              "name":"Neo4jSinkConnectorAVRO"
          },
          "tasks":[  
            {  
              "connector":"Neo4jSinkConnectorAVRO",
              "task":0
            }
          ],
          "type":"sink"
        }

7. Perform basic testing:

  - Download [neo4j-streams-sink-tester-1.0](https://github.com/conker84/neo4j-streams-sink-tester/releases/download/1/neo4j-streams-sink-tester-1.0.jar)

  - Use browser and login with password `##dis@da2019##` to `neo4j` at http://localhost:7474/browser/.

  - Create constraint and index to make persistence operation faster:

          CREATE INDEX ON :Person(surname);
          CREATE CONSTRAINT ON (f:Family) ASSERT f.name IS UNIQUE;

  ![Create constraint and index](images/create_indexes_for_testing.png)

  - Run test:

          java -jar neo4j-streams-sink-tester-1.0.jar -t avro-topic -f AVRO -e 50

          log4j:WARN No appenders could be found for logger (org.apache.kafka.clients.producer.ProducerConfig).
          log4j:WARN Please initialize the log4j system properly.
          log4j:WARN See http://logging.apache.org/log4j/1.2/faq.html#noconfig for more info.
          You are sending data in AVRO format

- Verify test results:

          MATCH (f:Family)-[]-(p:Person) RETURN f, p;

  ![Create constraint and index](images/test_graph.png)

### 2. Python client tests

1. Install `confluent_kafka` and Apache `avro` python packages.

        pip3 install confluent_kafka
        pip3 install avro-python3

    Note: [Apache Avro™](https://avro.apache.org) Apache Avro is a data serialization system. It provides:
    - Rich data structures.
    - A compact, fast, binary data format.
    - A container file, to store persistent data.
    - Remote procedure call (RPC).
    - Simple integration with dynamic languages. Code generation is not required to read or write data files nor to use or implement RPC protocols. Code generation as an optional optimization, only worth implementing for statically typed languages.


2. In a terminal, run command-line `test_kafka_consumer.sh` for consumer.

        ./test_kafka_consumer.sh my-topic

      This will wait for new messages.

3. In another terminal, run command-line `test_kafka_producer.sh` for producer:

        ./test_kafka_producer.sh my-topic Sinan Baltacioglu

        (3.7.3) nghias-mbp:session_4 nghia$ ./test_kafka_producer.sh my-topic Sinan Baltacioglu
        (3.7.3) nghias-mbp:session_4 nghia$ ./test_kafka_producer.sh my-topic Meghan Baltacioglu

      The terminal where `test_kafka_consumer.sh` should display below content:

        (3.7.3) nghias-mbp:session_4 nghia$ ./test_kafka_consumer.sh my-topic
        Press Ctrl+C when you want to stop the consumer.
        {'name': 'Sinan', 'surname': 'Baltacioglu'}
        {'name': 'Meghan', 'surname': 'Baltacioglu'}
        ^CTerminating ...

      Use Neo4j browser to show newly added entities and relationships:

      ![Testing adding entities and relationships](images/test_python_client.png)  

### 3. Node.js® client tests
