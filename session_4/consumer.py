import sys

from confluent_kafka import KafkaError
from confluent_kafka.avro import AvroConsumer
from confluent_kafka.avro.serializer import SerializerError

BROKER_HOST = 'localhost:9092'
SCHEMA_REGISTRY = 'http://localhost:8081'


if __name__ == "__main__":

    if len(sys.argv) < 2:
        print("Usage: python3 consumer.py <topic>")
        exit(1)

    topic = sys.argv[1]

    c = AvroConsumer({
        'bootstrap.servers': BROKER_HOST,
        'group.id': 'groupid',
        'schema.registry.url': SCHEMA_REGISTRY})

    c.subscribe([topic])

    while True:
        try:
            msg = c.poll(1)

        except SerializerError as e:
            print("Message deserialization failed for {}: {}".format(msg, e))
            break

        except KeyboardInterrupt:
            print("Terminating ...")
            c.close()
            exit(0)

        if msg is None:
            continue

        if msg.error():
            print("AvroConsumer error: {}".format(msg.error()))
            continue

        print(msg.value())

    c.close()
