#!/bin/bash

source _lib.sh
require "$1" \
  "$#" \
  1 \
  'Usage: sort_dataset.sh <filename>
Example: sort_dataset.sh file.txt

Sorts a dataset file by the first column.

Arguments:
  <filename>  The input file to sort.'

readonly FILENAME="$1"

if [[ ! -f "$FILENAME" ]] || [[ ! -r "$FILENAME" ]]; then
  die "'$FILENAME' does not exist or unreadable."
fi

main() {
  local filename_sorted="${FILENAME%.*}_sorted.${FILENAME##*.}"

  echo "Sorting '$FILENAME'..."
  sort -n -k1,1 "$FILENAME" > "$filename_sorted"

  echo "${GREEN}Output written to '$filename_sorted$END'."
}

duration=$(timed main "$FILENAME")

echo
echo "Total execution time: $BOLD$duration seconds$END"
echo 'Goodbye!'
exit 0
