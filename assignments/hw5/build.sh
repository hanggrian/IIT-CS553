#!/bin/bash

source _lib.sh

./gradlew clean build || die 'Build failed.'

echo
echo 'Goodbye!'
