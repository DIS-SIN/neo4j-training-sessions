#!/bin/bash

export NEO4J_GDB=$PWD/neo4j
echo $NEO4J_GDB

export NEO4J_GDB_CONF=$NEO4J_GDB/conf
export NEO4J_GDB_DATA=$NEO4J_GDB/data
export NEO4J_GDB_LOGS=$NEO4J_GDB/logs
export NEO4J_GDB_IMPT=$NEO4J_GDB/import

echo NEO4J_GDB_CONF=$NEO4J_GDB_CONF
echo NEO4J_GDB_DATA=$NEO4J_GDB_DATA
echo NEO4J_GDB_LOGS=$NEO4J_GDB_LOGS
echo NEO4J_GDB_IMPT=$NEO4J_GDB_IMPT
