#!/bin/bash

readonly END='[0m'
readonly BOLD='[1m'
readonly RED='[91m'
readonly GREEN='[92m'
readonly YELLOW='[93m'

readonly BUILD_DIRECTORY='build'

warn() { echo "$YELLOW$*$END"; } >&2

die() { echo; echo "$RED$*$END"; echo; exit 1; } >&2
