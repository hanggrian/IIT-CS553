#!/bin/bash

source _lib.sh

INPUT_DIR="/user/$(whoami)/dummy" && readonly INPUT_DIR
OUTPUT_DIR="/user/$(whoami)/sorted-hadoop" && readonly OUTPUT_DIR

if [[ ! -f "$JAR_FILE" ]]; then
  die 'JAR does not exist, build the project first.'
fi

if [[ -z "$HADOOP_HOME" ||
  -z "$HADOOP_COMMON_HOME" ||
  -z "$HADOOP_CONF_DIR" ]]; then
  die 'Hadoop variables are missing.'
fi

if ! hdfs dfs -test -e "$INPUT_DIR"; then
  hdfs dfs -mkdir -p "$INPUT_DIR"
  hdfs dfs -touchz "$INPUT_DIR/_empty"
fi
if hdfs dfs -test -e "$OUTPUT_DIR"; then
  hdfs dfs -rm -r "$OUTPUT_DIR"
fi
time hadoop jar \
  "$JAR_FILE" edu.illinoistech.hawk.hwijaya.HadoopVault \
  "$INPUT_DIR" \
  "$OUTPUT_DIR" \
  65536 \
  2 \
  2>&1 | tee hadoop.log
