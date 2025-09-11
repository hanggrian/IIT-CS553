#!/bin/bash

source _lib.sh
require "$1" \
  "$#" \
  1 \
  'Usage: network_benchmark.sh <filename> <server_output>
Example: network_benchmark.sh file.txt logs.txt

Executes a series of iperf network benchmark.

Arguments:
  <filename>  Input file of iperf -s command result.'

readonly FILENAME="$1"

readonly WINDOW_SIZE='2.5M'
readonly IP_ADDRESS='127.0.0.1'
readonly INTERVAL=1
readonly WRITE_BUFFER_SIZE='8192K'

if [[ ! -f "$FILENAME" ]] || [[ ! -r "$FILENAME" ]]; then
  die "'$FILENAME' does not exist or unreadable."
fi

warn 'This script needs a running server in the localhost.'
echo

benchmark() {
  local thread_count=$1
  iperf \
    -c $IP_ADDRESS \
    -w $WINDOW_SIZE \
    -i $INTERVAL \
    --nodelay \
    -l $WRITE_BUFFER_SIZE \
    --trip-times \
    --parallel "$thread_count" > /dev/null
}

total_duration=0
for thread_count in "${THREAD_COUNTS[@]}"; do
  echo "Testing $thread_count threads..."

  start_time=$(date +%s)
  benchmark "$thread_count"
  total_duration=$((total_duration + $(($(date +%s) - start_time))))
done

echo 'Filtering...'
filename_sorted="${FILENAME%.*}_sorted.${FILENAME##*.}"
grep -E "^\[  *1\] 0\.00-10|^\[SUM-(2|4|8|16|32|64)\]" "$FILENAME" |
  while read -r line; do
    if [[ $line =~ ^\[\ *1\] ]]; then
      thread_count=1
      latency=$(echo "$line" | awk '{print $5}')
      throughput=$(echo "$line" | awk '{print $7}')
    elif [[ $line =~ ^\[SUM-([0-9]+)\] ]]; then
      thread_count=${BASH_REMATCH[1]}
      latency=$(echo "$line" | awk '{print $4}')
      throughput=$(echo "$line" | awk '{print $6}')
    else
      continue
    fi

    echo "$thread_count $latency $throughput"
  done > "$filename_sorted"
echo "${GREEN}Output written to '$filename_sorted$END'."
echo 'Benchmark complete.'

echo
echo "Total execution time: $BOLD$total_duration seconds$END"
echo 'Goodbye!'
exit 0
