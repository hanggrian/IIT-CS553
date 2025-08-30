#!/bin/bash
#!/bin/bash

readonly END='[0m'
readonly BOLD='[1m'
readonly RED='[91m'
readonly GREEN='[92m'

die() { echo; echo "$RED$*$END"; echo; exit 1; } >&2

if [[ "$#" -ne 1 ]]; then
  die 'For usage information, run with the help flag '-h'.'
elif [[ "$1" == '-h' || "$1" == '--help' ]]; then
  echo 'Usage: sort-data.sh <filename>'
  echo 'Example: sort-data.sh file.txt'
  echo
  echo 'Sorts a dataset file by the first column.'
  echo
  echo 'Arguments:'
  echo '  <filename>  The input file to sort.'
  exit 0
fi

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

start_time=$(date +%s)
(time main "$FILENAME") 2>/dev/null
duration=$(($(date +%s) - start_time))

echo
echo "Total execution time: $BOLD$duration seconds$END"
echo 'Goodbye!'
exit 0
