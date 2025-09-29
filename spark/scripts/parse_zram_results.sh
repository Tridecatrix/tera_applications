#!/bin/bash
# filepath: c:\Users\adnan\Desktop\Work\2025\COMP4550_Honours\tera_applications\spark\scripts\parse_zram_results.sh

RESULT_DIR=$1

if [[ -z "$RESULT_DIR" ]]; then
    echo "Usage: $0 <result_directory>"
    exit 1
fi

# Single awk command to process all data
awk '
BEGIN {
    data_total = 0
    compr_total = 0
    count = 0
    first_data_bytes = 0
    startup_skipped = 0
    ratio_total = 0
    ratio_sum_sq = 0
    max_data = 0
    max_compr = 0
    first_set = 0
}

$1 == "mmstat" {
    # Get DATA and TOTAL columns (fields 2 and 3)
    data_bytes = $2
    compr_bytes = $3
    
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
    
    # Accumulate data
    data_total += data_bytes
    compr_total += compr_bytes
    max_data = (max_data > data_bytes) ? max_data : data_bytes
    max_compr = (max_compr > compr_bytes) ? max_compr : compr_bytes
    count++
    
    # Calculate ratio and accumulate for standard deviation
    if (compr_bytes > 0) {
        ratio = data_bytes / compr_bytes
        ratio_total += ratio
        ratio_sum_sq += ratio * ratio
    }
}

END {
    if (count == 0) {
        print "No entries found (or all entries were during startup time)"
        print "Startup entries skipped: " startup_skipped
        exit 1
    }
    
    # Calculate averages in MiB
    avg_data = data_total / count / 1048576
    avg_compr = compr_total / count / 1048576
    avg_ratio = ratio_total / count
    
    # Calculate standard deviation of compression ratio
    if (count > 1) {
        variance = (ratio_sum_sq - (ratio_total * ratio_total / count)) / (count - 1)
        ratio_stddev = sqrt(variance)
    } else {
        ratio_stddev = 0
    }
    
    # Convert max values to MiB
    max_data_mb = max_data / 1048576
    max_compr_mb = max_compr / 1048576
    ratio_at_max = (max_compr > 0) ? max_data / max_compr : 0
    
    # Output as CSV
    printf "AVG_DATA_SIZE_MB,%.2f\n", avg_data
    printf "AVG_COMPR_SIZE_MB,%.2f\n", avg_compr
    printf "AVG_RATIO,%.2f\n", avg_ratio
    printf "RATIO_STDDEV,%.4f\n", ratio_stddev
    printf "MAX_DATA_SIZE_MB,%.2f\n", max_data_mb
    printf "MAX_COMPR_SIZE_MB,%.2f\n", max_compr_mb
    printf "RATIO_AT_MAX_DATA_SIZE,%.2f\n", ratio_at_max
    printf "STARTUP_ENTRIES_SKIPPED,%d\n", startup_skipped
}
' "$RESULT_DIR/zram_usage.txt"