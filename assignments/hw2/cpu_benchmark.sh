#!/bin/bash

source _lib.sh
require "$1" \
  "$#" \
  1 \
  'Usage: cpu_benchmark.sh <filename>
Example: cpu_benchmark.sh file.txt

Executes a series of sysbench CPU benchmark.

Arguments:
  <filename>  The name of the output file to create.'

readonly FILENAME="$1"

readonly MAX_PRIME=100000

if ! [[ "$FILENAME" == *.* ]]; then
  die 'Missing file extension.'
fi

benchmark() {
  local thread_count=$1
  local sysbench_output && sysbench_output=$(sysbench cpu \
    --cpu-max-prime=$MAX_PRIME \
    --threads="$thread_count" \
    run)

  average_latency=$(echo "$sysbench_output" | \
    grep 'avg:' | \
    awk '{print $NF}')
  throughput=$(echo "$sysbench_output" | \
    grep 'events per second:' | \
    awk '{print $NF}')
  echo "$average_latency $throughput"
}

echo "Preparing '$FILENAME'..."
true > "$FILENAME"

total_duration=0
for thread_count in "${THREAD_COUNTS[@]}"; do
  echo "Testing $thread_count threads..."

  start_time=$(date +%s)
  result=$(benchmark "$thread_count")
  total_duration=$((total_duration + $(($(date +%s) - start_time))))

  echo "$thread_count $result" >> "$FILENAME"
  echo "${GREEN}Recorded $(echo "$result" | awk '{print $2}') events/sec.$END"
done
echo 'Benchmark complete.'

echo
echo "Total execution time: $BOLD$total_duration seconds$END"
echo 'Goodbye!'
exit 0
