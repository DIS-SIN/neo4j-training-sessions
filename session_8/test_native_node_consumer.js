"use strict";

const { NConsumer } = require("sinek");

const kafkaTopics = ["json-topic", "avro-topic"];

const consumerConfiguration = {
    noptions: {
        "metadata.broker.list": "localhost:9092",
        "group.id": "nodejs-group",
        "enable.auto.commit": false,
        "socket.keepalive.enable": true,
        "api.version.request": true,
        "socket.blocking.max.ms": 100,
    },
    tconf: {
        "auto.offset.reset": "earliest",
    },
};

const batchOptions = {
    batchSize: 1000,
    commitEveryNBatch: 1,
    manualBatching: true,
};

(async () => {
    const consumer = new NConsumer(kafkaTopics, consumerConfiguration);
    consumer.on("error", (error) => console.error(error));
    await consumer.connect();
    consumer.consume(async (messages, callback) => {
        // deal with array of messages
        // and when your done call the callback to commit (depending on your batch settings)
        console.log(messages);
        callback();
    }, true, false, batchOptions);
})().catch(console.error);
