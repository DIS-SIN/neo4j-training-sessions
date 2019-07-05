import sys

from confluent_kafka import avro
from confluent_kafka.avro import AvroProducer

BROKER_HOST = 'localhost:9092'
SCHEMA_REGISTRY = 'http://localhost:8081'

VALUE_SCHEMA_STR = """
{
    "namespace": "ca.gov.tbs.csps.da.dis",
	"name": "User",
	"type": "record",
	"fields": [
		{"name": "name", "type": "string"},
		{"name": "surname",  "type": "string"}
	]
}
"""
VALUE_SCHEMA = avro.loads(VALUE_SCHEMA_STR)


if __name__ == "__main__":

    if len(sys.argv) < 4:
        print("Usage: python3 producer.py <topic> <name> <surname>")
        exit(1)

    topic = sys.argv[1]
    value = {"name": sys.argv[2], "surname": sys.argv[3]}

    avroProducer = AvroProducer({
        'bootstrap.servers': BROKER_HOST,
        'schema.registry.url': SCHEMA_REGISTRY
        }, default_value_schema=VALUE_SCHEMA)

    avroProducer.produce(topic=topic, value=value)
    avroProducer.flush()
