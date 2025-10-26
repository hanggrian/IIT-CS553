#!/bin/bash

source _lib.sh

cd "$BUILD_DIRECTORY" || die 'Build directory not found.'

warn 'Long running benchmarks, pause with Ctrl+S and resume with Ctrl+Q.'

if [ ! -f ./vaultx ]; then
  die 'Executable file not found.'
fi

prompt_yn() {
  while true; do
    read -r -p "$1 (y/n)? " yn
    case $yn in
        [Yy]*) return 0;;
        [Nn]*) return 1;;
        *) warn 'Unknown input.';;
    esac
  done
}

if prompt_yn 'Run small benchmarks?'; then
  echo "${BOLD}Running small benchmarks:$END"
  for threads in 1 2 4 8 12 24 48; do
    for memory in 256 512 1024; do
      for io_threads in 1 2 4; do
        ./vaultx -t "$threads" -i "$io_threads" -m "$memory" -k 26 -a task
      done
    done
  done
  echo
fi

if prompt_yn 'Run large benchmarks?'; then
  echo "${BOLD}Running large benchmarks:$END"
  for memory in 1024 2048 4096 8192 16384 32768 65536; do
    ./vaultx -t 24 -i 1 -m "$memory" -k 32 -a task
  done
  echo
fi

if prompt_yn 'Run search benchmarks?'; then
  echo "${BOLD}Running search benchmarks:$END"
  for k in 26 32; do
    for difficulty in 3 4 5; do
      ./vaultx -k "$k" -q "$difficulty" -s 1000 -a task
    done
  done
  echo
fi

echo "${GREEN}All benchmarks completed.$END"
echo 'Goodbye!'
