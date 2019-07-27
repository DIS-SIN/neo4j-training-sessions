"use strict";

const {Producer} = require("sinek");
const producer = new Producer(require("./test_node_config.js"), ["json-topic"], 1);

producer.on("error", error => console.error(error));

let message = "*** Message in a bottle ***";

producer.connect().then(() => {
  console.log("connected.");
  setInterval(() => {
    console.log("send " + message);
    producer.send("json-topic", message);
  }, 1000);
}).catch(error => console.error(error));
