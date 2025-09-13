#!/bin/bash

readonly END='[0m'
readonly BOLD='[1m'
readonly RED='[91m'
readonly GREEN='[92m'
readonly YELLOW='[93m'

readonly THREAD_COUNTS=(1 2 4 8 16)

warn() { echo "$YELLOW$*$END"; } >&2

die() { echo; echo "$RED$*$END"; echo; exit 1; } >&2

require() {
  local first_param=$1
  local current_param_count=$2
  local max_param_count=$3
  local help_message=$4

  if [[ "$first_param" == '-h' || "$first_param" == '--help' ]]; then
    echo "$help_message"
    exit 0
  elif [[ $current_param_count -ne $max_param_count ]]; then
    die "For usage information, run with the help flag '-h'."
  fi
}
