#!/bin/bash

source _lib.sh
require "$1" \
  "$#" \
  1 \
  "Usage: network_benchmark_server.sh <filename>
Example: network_benchmark_server.sh file.txt

Starts an iperf server for memory benchmark triggered by the client. The output
file of this command should be used as an input in the client's command.

Arguments:
  <filename>  The name of the output file to create."

readonly FILENAME="$1"

readonly WINDOW_SIZE='1M'

if ! [[ "$FILENAME" == *.* ]]; then
  die 'Missing file extension.'
fi

warn 'The server keeps on listening until explicitly stopped.'
echo

echo "Preparing '$FILENAME'..."
true > "$FILENAME"

echo 'Listening...'
iperf -s -w $WINDOW_SIZE > "$FILENAME"
