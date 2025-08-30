#!/bin/bash

readonly END='[0m'
readonly BOLD='[1m'
readonly RED='[91m'
readonly GREEN='[92m'
readonly YELLOW='[93m'

warn() { echo "$YELLOW$*$END"; } >&2
die() { echo; echo "$RED$*$END"; echo; exit 1; } >&2

if [[ "$#" -ne 2 ]]; then
  die "For usage information, run with the help flag '-h'."
elif [[ "$1" == '-h' || "$1" == '--help' ]]; then
  echo 'Usage: generate_dataset.sh <filename> <num_records>'
  echo 'Example: generate_dataset.sh file.txt 100'
  echo
  echo 'Generates a benchmark report and logs its completion in the background.'
  echo
  echo 'Arguments:'
  echo '  <filename>     The name of the output file to create.'
  echo '  <num_records>  The number of records to generate.'
  exit 0
fi

readonly FILENAME="$1"
readonly NUM_RECORDS="$2"
readonly MAX_DURATION=10

CHARACTERS="!\"#\$%&'()*+,-./0123456789:;<=>?@" && \
  CHARACTERS+="ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^\`" && \
  CHARACTERS+="abcdefghijklmnopqrstuvwxyz{|}~" && \
  readonly CHARACTERS

if ! [[ "$NUM_RECORDS" =~ ^[0-9]+$ ]] || [ "$NUM_RECORDS" -le 0 ]; then
  die 'Non-positive number of records.'
fi

random_32bit_int() { echo "$SRANDOM"; }

random_ascii_string() {
  local result=''
  for ((i=0; i<100; i++)); do
    local j=$((RANDOM % ${#CHARACTERS}))
    result="${result}${CHARACTERS:$j:1}"
  done
  echo "$result"
}

main() {
  echo "Preparing '$FILENAME'..."
  true > "$FILENAME"

  echo -n 'Writing entries'
  for ((i=1; i<=NUM_RECORDS; i++)); do
    echo "$(random_32bit_int) $(random_32bit_int) $(random_ascii_string)" >> \
      "$FILENAME"

    local quarter=$((NUM_RECORDS / 4))
    if [[ $((i % quarter)) -eq 0 ]] && [[ "$quarter" -gt 0 ]]; then
      echo -n "...$((i * 100 / NUM_RECORDS))%"
    fi
  done

  echo
  echo "${GREEN}Created $NUM_RECORDS records.$END"
}

start_time=$(date +%s)
(time main "$FILENAME" "$NUM_RECORDS") 2>/dev/null
duration=$(($(date +%s) - start_time))

echo
echo "Total execution time: $BOLD$duration seconds$END"
echo

if [[ "$duration" -lt "$MAX_DURATION" ]]; then
  warn 'Benchmark completed in less than 10 seconds, waiting...'
  sleep $((MAX_DURATION - duration))
fi

echo 'Goodbye!'
exit 0
