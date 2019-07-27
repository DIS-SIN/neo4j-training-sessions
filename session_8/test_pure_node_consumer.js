"use strict";

const {Consumer} = require("sinek");
const consumer = new Consumer("json-topic", require("./test_node_config.js"));

consumer.on("error", error => console.error(error));

consumer.connect(false).then(() => {
  console.log("connected");
  consumer.consume();

}).catch(error => console.error(error));

consumer.on("message", message => console.log(message.value.toString()));
