#!/bin/bash

source _lib.sh

# install gnuplot plotutils

if [[ ! -f vmstat.log ]]; then
  die "Run run 'vmstat 1 > vmstat.log' to collect performance data."
fi

tail -n +3 vmstat.log | grep -v ' r ' | grep -v 'Average' | sed '/^$/d' > vmstat_data.log
echo "Generating plot..."
gnuplot << 'EOF'
set terminal png size 900,500
set output 'figure.png'

set title 'CPU and Memory utilization over time'
set xlabel 'Sample Index (Time)'
set grid
set datafile separator whitespace # Crucial for vmstat output

set ylabel 'CPU Idle (%)'
set yrange [0:100]
set ytics nomirror

set y2label 'Memory (MiB)'
set y2tics

plot \
  'vmstat_data.log' using 15 with lines title 'CPU Idle (%)' axis x1y1, \
  'vmstat_data.log' using ($4/1024) with lines title 'Memory (MiB)' axis x1y2
EOF
