#!/bin/bash

readonly END='[0m'
readonly BOLD='[1m'
readonly RED='[91m'
readonly GREEN='[92m'
readonly YELLOW='[93m'

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

timed() {
  local start_time && start_time=$(date +%s)

  "$@" >&2
  echo $(($(date +%s) - start_time))
}
