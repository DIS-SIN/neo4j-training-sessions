const debug = require("debug");
const fs = require("fs");

const config = {
  kafkaHost: "localhost:9092",
  logger: {
    debug: debug("sinek:debug"),
    info: debug("sinek:info"),
    warn: debug("sinek:warn"),
    error: debug("sinek:error")
  },
  groupId: "nodejs-group",
  clientName: "nodejs-client",
  workerPerPartition: 1,
  options: {
    sessionTimeout: 8000,
    protocol: ["roundrobin"],
    fromOffset: "latest",
    fetchMaxBytes: 1024 * 1024,
    fetchMinBytes: 1,
    fetchMaxWaitMs: 10,
    heartbeatInterval: 250,
    retryMinTimeout: 250,
    autoCommit: true,
    autoCommitIntervalMs: 1000,
    requireAcks: 1,
    ackTimeoutMs: 100,
    partitionerType: 3
  }
};

module.exports = config;
