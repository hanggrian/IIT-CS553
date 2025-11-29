#!/bin/bash

source _lib.sh

./gradlew shadowJar || die 'Build failed.'

echo
echo 'Goodbye!'
