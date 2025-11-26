#!/bin/bash

source _lib.sh

cd "$BUILD_DIRECTORY" || die 'Build directory not found.'

if [[ ! -f ./hashgen ]]; then
  die 'Executable file not found.'
fi

echo "${BOLD}Showing help command:$END"
./hashgen -h

echo "${BOLD}Testing threads & OpenMP with minimal configuration:$END"
minimal_args=(
  -t 4
  -i 0
  -m 128
  -k 20
  -g memo.t
  -f k20-memo.x
  -d
)
./hashgen "${minimal_args[@]}"
./hashgen "${minimal_args[@]}" -a task
echo

echo "${BOLD}Testing verification & searching with small configuration:$END"
small_args=(
  -t 24
  -i 1
  -m 256
  -k 26
  -g memo.t
  -f k26-memo.x
  -d
)
./hashgen "${small_args[@]}" -a task
./hashgen "${small_args[@]}" -v
./hashgen "${small_args[@]}" -s 10 -q 3
echo

echo "${GREEN}All tests completed.$END"
echo 'Goodbye!'
