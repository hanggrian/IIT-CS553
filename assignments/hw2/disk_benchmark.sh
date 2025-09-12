#!/bin/bash

source _lib.sh
require "$1" \
  "$#" \
  1 \
  'Usage: disk_benchmark.sh <filename>
Example: disk_benchmark.sh file.txt

Executes a series of sysbench IO benchmark.

Arguments:
  <filename>  The name of the output file to create.'

readonly FILENAME="$1"

readonly NUM='2'
readonly BLOCK_SIZE=4096
readonly TOTAL_SIZE='2G'
readonly TEST_MODE='rndrd'
readonly IO_MODE='sync'
readonly EXTRA_FLAGS='direct'

if ! [[ "$FILENAME" == *.* ]]; then
  die 'Missing file extension.'
fi

benchmark() {
  local thread_count=$1
  local sysbench_command=(
    'sysbench' 'fileio'
    "--file-num=$NUM"
    "--file-block-size=$BLOCK_SIZE"
    "--file-total-size=$TOTAL_SIZE"
    "--file-test-mode=$TEST_MODE"
    "--file-io-mode=$IO_MODE"
    "--file-extra-flags=$EXTRA_FLAGS"
    "--threads=$thread_count"
  )

  "${sysbench_command[@]}" prepare > /dev/null 2>&1
  local sysbench_output && sysbench_output=$("${sysbench_command[@]}" run)
  "${sysbench_command[@]}" cleanup > /dev/null 2>&1

  operations=$(echo "$sysbench_output" | \
    grep 'total number of events:' | \
    awk '{print $NF}')
  throughput=$(echo "$sysbench_output" | \
    grep 'read, MiB/s:' | \
    awk '{print $NF}')
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
