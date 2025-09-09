#!/bin/bash

RESULT_DIR=$1
DEV_H2=$2

data_total=0
compr_total=0
count=0
first_data_value=""
first_data_bytes=0
startup_skipped=0
ratio_total=0

# Extract lines for the device and process each
while read -r line; do
    # Get DATA and TOTAL columns (fields 4 and 6)
    data=$(echo "$line" | awk '{print $4}')
    compr=$(echo "$line" | awk '{print $6}')

    # Convert sizes to MiB (handles M and G)
    data_bytes=$(numfmt --from=iec "$data")
    compr_bytes=$(numfmt --from=iec "$compr")

    # Store the first data value to identify startup time baseline
    if [ -z "$first_data_value" ]; then
        first_data_value="$data"
        first_data_bytes=$data_bytes
    fi

    # Skip entries during startup time (when data is within 10% of initial value)
    # Calculate 10% tolerance using awk
    tolerance_check=$(awk "BEGIN {
        diff = ($data_bytes > $first_data_bytes) ? $data_bytes - $first_data_bytes : $first_data_bytes - $data_bytes;
        percent_diff = (diff / $first_data_bytes) * 100;
        print (percent_diff <= 10) ? 1 : 0
    }")
    
    if [ "$tolerance_check" -eq 1 ]; then
        startup_skipped=$((startup_skipped + 1))
        continue
    fi

    data_total=$((data_total + data_bytes))
    compr_total=$((compr_total + compr_bytes))
    max_data=$((max_data > data_bytes ? max_data : data_bytes))
    max_compr=$((max_compr > compr_bytes ? max_compr : compr_bytes))
    count=$((count + 1))

    # Calculate ratio using awk (avoid bc dependency)
    ratio=$(awk "BEGIN {printf \"%.2f\", $data_bytes / $compr_bytes}")
    ratio_total=$(awk "BEGIN {printf \"%.6f\", $ratio_total + $ratio}")
done < <(grep "$DEV_H2" "$RESULT_DIR/zram_usage.txt")

if [ "$count" -eq 0 ]; then
    echo "No entries found for $DEV_H2 (or all entries were during startup time)"
    echo "Startup entries skipped: $startup_skipped"
    exit 1
fi
    
# Calculate averages in MiB using awk (avoid bc dependency)
avg_data=$(awk "BEGIN {printf \"%.2f\", $data_total / $count / 1048576}")
avg_compr=$(awk "BEGIN {printf \"%.2f\", $compr_total / $count / 1048576}")
avg_ratio=$(awk "BEGIN {printf \"%.2f\", $ratio_total / $count}")

# Convert max values to MiB using awk
max_data_mb=$(awk "BEGIN {printf \"%.2f\", $max_data / 1048576}")
max_compr_mb=$(awk "BEGIN {printf \"%.2f\", $max_compr / 1048576}")
ratio_at_max=$(awk "BEGIN {printf \"%.2f\", $max_data / $max_compr}")

# Output as CSV: avg_data_size(MiB),avg_compr_size(MiB),avg_compr_ratio
echo "AVG_DATA_SIZE_MB,$avg_data"
echo "AVG_COMPR_SIZE_MB,$avg_compr"
echo "AVG_RATIO,$avg_ratio"
# Output max values as CSV: max_data_size(MiB),max_compr_size(MiB),max_compr_ratio  
echo "MAX_DATA_SIZE_MB,$max_data_mb"
echo "MAX_COMPR_SIZE_MB,$max_compr_mb"
echo "RATIO_AT_MAX_DATA_SIZE,$ratio_at_max"
echo "STARTUP_ENTRIES_SKIPPED,$startup_skipped"
