#!/bin/bash

source _lib.sh

OUTPUT_DIR="/user/$(whoami)/sorted-spark" && readonly OUTPUT_DIR

if [[ ! -f "$JAR_FILE" ]]; then
  die 'JAR does not exist, build the project first.'
fi

if [[ -z "$SPARK_HOME" ]]; then
  die 'Spark variable is missing.'
fi

if hdfs dfs -test -e "$OUTPUT_DIR"; then
  hdfs dfs -rm -r "$OUTPUT_DIR"
fi
time spark-submit \
  --class edu.illinoistech.hawk.hwijaya.SparkVault \
  --master yarn \
  --deploy-mode cluster \
  --num-executors 1 \
  --executor-cores 1 \
  --executor-memory 1g \
  "$JAR_FILE" \
  "hdfs://$OUTPUT_DIR" \
  1048576 \
  4 \
  2>&1 | tee spark.log
