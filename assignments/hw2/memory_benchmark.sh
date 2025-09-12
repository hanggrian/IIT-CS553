#!/bin/bash

source _lib.sh
require "$1" \
  "$#" \
  1 \
  'Usage: memory_benchmark.sh <filename>
Example: memory_benchmark.sh file.txt

Executes a series of sysbench memory benchmark.

Arguments:
  <filename>  The name of the output file to create.'

readonly FILENAME="$1"

readonly BLOCK_SIZE='1K'
readonly TOTAL_SIZE='120G'
readonly OPER='read'
readonly ACCESS_MODE='rnd'

if ! [[ "$FILENAME" == *.* ]]; then
  die 'Missing file extension.'
fi

benchmark() {
  local thread_count=$1
  local sysbench_output && sysbench_output=$(sysbench memory \
    --memory-block-size=$BLOCK_SIZE \
    --memory-total-size=$TOTAL_SIZE \
    --memory-oper=$OPER \
    --memory-access-mode=$ACCESS_MODE \
    --threads="$thread_count" \
    run)

  operations=$(echo "$sysbench_output" | \
    grep 'total number of events:' | \
    awk '{print $NF}')
  throughput=$(echo "$sysbench_output" | \
    grep 'transferred' | \
    awk '{print $1}')
  echo "$operations $throughput"
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
  echo "${GREEN}Recorded $(echo "$result" | awk '{print $2}') MiB/sec.$END"
done
echo 'Benchmark complete.'

echo
echo "Total execution time: $BOLD$total_duration seconds$END"
echo 'Goodbye!'
exit 0
