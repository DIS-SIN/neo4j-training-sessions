"use strict";

const { NProducer } = require("sinek");

const producerConfiguration = {
    noptions: {
        "metadata.broker.list": "yggdrasil_broker:9093",
        "client.id": "nodejs-client",
        "compression.codec": "none",
        "socket.keepalive.enable": true,
        "api.version.request": true,
        "queue.buffering.max.ms": 1000,
        "batch.num.messages": 500,
      },
      tconf: {
        "request.required.acks": 1
      },
};

// amount of partitions of the topics this consumer produces to
const partitionCount = 1; // all messages to partition 0

(async () => {
    const producer = new NProducer(producerConfiguration, null, partitionCount);
    producer.on("error", error => console.error(error));
    await producer.connect();
    const { offset } = await producer.send("json-topic", "Message in a bottle!", 0, "my-key", "my-partition-key");
    console.log("Sent: " + "Message in a bottle!")
})().catch(console.error);
