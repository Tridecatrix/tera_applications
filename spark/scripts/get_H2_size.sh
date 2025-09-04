#!/bin/bash

usage() {
    echo
    echo "Usage:"
    echo "      $0 -r rdir"
    echo "Options:"
    echo "      -r  Path to results directory"
    echo "      -h  Show usage"
    echo
    exit 1
}

while getopts ":r:h" opt
do
    case "${opt}" in
        r)
            RDIR=${OPTARG}
            ;;
        h)
            usage
            ;;
        *)
            usage
            ;;
    esac
done

if [[ -z $RDIR ]]; then
    usage
    exit
fi

for FILE in $(find "$RDIR" -name teraHeap.txt); do
    RUNNAME=$(dirname $FILE)
    VALUE=$(grep "TOTAL_OBJECTS_SIZE" "$FILE" | awk 'max<$5{max=$5} END{print max}')
    # NOTE: TOTAL_OBJECTS_SIZE IS ACTUALLY IN WORDS WHICH (as far as I can tell) MEANS 8 BYTES
    echo "$RUNNAME: $(echo "scale=2; $VALUE * 8 / 1024.0 / 1024.0 / 1024.0" | bc -l) GB"
done