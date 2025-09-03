#!/bin/bash

if [ $# -ne 1 ]; then
    echo "usage: ./clear.sh [conf]"
    exit
fi

CONF=$1
. ./$CONF

# Clear H2 and Shuffle
find "$MNT_H2" -mindepth 1 \
    \( -name 'SparkBench' -o -name 'lost+found' \) -prune \
    -o -exec rm -r {} +
find "$MNT_SHFL" -mindepth 1 \
    \( -name 'SparkBench' -o -name 'lost+found' \) -prune \
    -o -exec rm -r {} +

./clear-proc.sh
