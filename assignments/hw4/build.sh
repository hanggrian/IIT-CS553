#!/bin/bash

source _lib.sh

mkdir -p "$BUILD_DIRECTORY"
cd "$BUILD_DIRECTORY" || die 'Build directory not found.'

echo "${BOLD}Building with default nonce and hash size:$END"
cmake ..
cmake --build .

echo
echo 'Goodbye!'
