#!/bin/bash

echo 'Destroying JPS instances...'
stop-dfs.sh
stop-yarn.sh
stop-master.sh

echo
echo 'Goodbye!'
