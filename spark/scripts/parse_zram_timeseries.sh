#!/bin/bash
# filepath: c:\Users\adnan\Desktop\Work\2025\COMP4550_Honours\tera_applications\spark\scripts\parse_zram_timeseries.sh
# Script to extract compression ratio timeseries from zram_usage.txt files

RESULT_DIR=$1
DEV_H2=$2

if [[ -z "$RESULT_DIR" || -z "$DEV_H2" ]]; then
    echo "Usage: $0 <result_directory> <dev_h2>"
    echo "Example: $0 /path/to/results /dev/zram2"
    exit 1
fi

# Single awk command to process all data and output timeseries
awk '
BEGIN {
    entry_count = 0
    
    # Print CSV header
    print "TimePoint,DataBytes,ComprBytes,Ratio"
}

# Only process lines containing the device
$1 == "mmstat" {
    # Get DATA and TOTAL columns (fields 2 and 3)
    data_bytes = $2
    compr_bytes = $3
    
    # Calculate ratio
    if (compr_bytes > 0) {
        ratio = data_bytes / compr_bytes
    } else {
        ratio = 0
    }
    
    # Output the timeseries data point
    printf "%d,%.0f,%.0f,%.4f\n", entry_count, data_bytes, compr_bytes, ratio
    entry_count++
}

END {
    if (entry_count == 0) {
        print "# No entries found" > "/dev/stderr"
        exit 1
    }
    
    print "# Total entries: " entry_count > "/dev/stderr"
}
' "$RESULT_DIR/zram_usage.txt"
