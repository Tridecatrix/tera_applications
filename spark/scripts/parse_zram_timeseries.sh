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
awk -v dev="$DEV_H2" '
BEGIN {
    entry_count = 0
    first_data_bytes = 0
    startup_skipped = 0
    first_set = 0
    
    # Print CSV header
    print "TimePoint,DataBytes,ComprBytes,Ratio"
}

# Only process lines containing the device
$0 ~ dev {
    # Get DATA and TOTAL columns (fields 4 and 6)
    data = $4
    compr = $6
    
    # Convert sizes to bytes (handles M and G suffixes)
    if (match(data, /([0-9.]+)([MG])/, arr)) {
        data_bytes = arr[1] * (arr[2] == "G" ? 1073741824 : 1048576)
    } else {
        data_bytes = data
    }
    
    if (match(compr, /([0-9.]+)([MG])/, arr)) {
        compr_bytes = arr[1] * (arr[2] == "G" ? 1073741824 : 1048576)
    } else {
        compr_bytes = compr
    }
    
    # Set first data value for startup baseline
    if (!first_set) {
        first_data_bytes = data_bytes
        first_set = 1
    }
    
    # Skip startup entries (within 10% of initial value)
    diff = (data_bytes > first_data_bytes) ? data_bytes - first_data_bytes : first_data_bytes - data_bytes
    percent_diff = (diff / first_data_bytes) * 100
    
    if (percent_diff <= 10) {
        startup_skipped++
        next
    }
    
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
        print "# No entries found for " dev " (or all entries were during startup time)" > "/dev/stderr"
        print "# Startup entries skipped: " startup_skipped > "/dev/stderr"
        exit 1
    }
    
    print "# Total entries: " entry_count > "/dev/stderr"
    print "# Startup entries skipped: " startup_skipped > "/dev/stderr"
}
' "$RESULT_DIR/zram_usage.txt"
