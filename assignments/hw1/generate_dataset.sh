#!/bin/bash

source _lib.sh
require "$1" \
  "$#" \
  2 \
  'Usage: generate_dataset.sh <filename> <record_count>
Example: generate_dataset.sh file.txt 100

Generates a benchmark report and logs its completion in the background.

Arguments:
  <filename>     The name of the output file to create.
  <record_count> The number of records to generate.'

readonly FILENAME="$1"
readonly RECORD_COUNT="$2"

readonly MAX_DURATION=10

CHARACTERS="!\"#\$%&'()*+,-./0123456789:;<=>?@" && \
  CHARACTERS+="ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^\`" && \
  CHARACTERS+="abcdefghijklmnopqrstuvwxyz{|}~" && \
  readonly CHARACTERS

if ! [[ "$FILENAME" == *.* ]]; then
  die 'Missing file extension.'
fi
if ! [[ "$RECORD_COUNT" =~ ^[0-9]+$ ]] || [ "$RECORD_COUNT" -le 0 ]; then
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
  for ((i=1; i<=RECORD_COUNT; i++)); do
    echo "$(random_32bit_int) $(random_32bit_int) $(random_ascii_string)" >> \
      "$FILENAME"

    local quarter=$((RECORD_COUNT / 4))
    if [[ $((i % quarter)) -eq 0 ]] && [[ "$quarter" -gt 0 ]]; then
      echo -n "...$((i * 100 / RECORD_COUNT))%"
    fi
  done

  echo
  echo "${GREEN}Created $RECORD_COUNT records.$END"
}

duration=$(timed main "$FILENAME" "$RECORD_COUNT")

echo
echo "Total execution time: $BOLD$duration seconds$END"
echo

if [[ "$duration" -lt "$MAX_DURATION" ]]; then
  warn 'Benchmark completed in less than 10 seconds, waiting...'
  sleep $((MAX_DURATION - duration))
fi

echo 'Goodbye!'
exit 0
