"use strict";

const { NConsumer } = require("sinek");

import express from 'express';
import { createServer } from 'http';
import { PubSub } from 'apollo-server';
import { ApolloServer, gql } from 'apollo-server-express';

const app = express();

const pubsub = new PubSub();
const MESSAGE_CREATED = 'MESSAGE_CREATED';

const typeDefs = gql`
  type Query {
    messages: [Message!]!
  }

  type Subscription {
    messageCreated: Message
  }

  type Message {
    id: String
    content: String
  }
`;

const resolvers = {
  Query: {
    messages: () => [
      { id: 0, content: 'Hello!' },
      { id: 1, content: 'Bye!' },
    ],
  },
  Subscription: {
    messageCreated: {
      subscribe: () => pubsub.asyncIterator(MESSAGE_CREATED),
    },
  },
};

const server = new ApolloServer({
  typeDefs,
  resolvers,
});

server.applyMiddleware({ app, path: '/graphql' });

const httpServer = createServer(app);
server.installSubscriptionHandlers(httpServer);

httpServer.listen({ port: 8000 }, () => {
  console.log('Apollo Server on http://localhost:8000/graphql');
});

let id = 2;

// setInterval(() => {
//   pubsub.publish(MESSAGE_CREATED, {
//     messageCreated: { id, content: new Date().toString() },
//   });
//
//   id++;
// }, 1000);

const kafkaTopics = ["json-topic", "avro-topic", "x.people", "x.relation"];

const consumerConfiguration = {
    noptions: {
        "metadata.broker.list": "yggdrasil_broker:9093",
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

        messages.forEach(function(message) {
          pubsub.publish(MESSAGE_CREATED, {
            messageCreated: { id, content: message.value.toString() },
          });
          id++;
        });

        callback();
    }, true, false, batchOptions);
})().catch(console.error);
