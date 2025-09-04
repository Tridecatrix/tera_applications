#!/bin/bash

RESULT_DIR=$1
DEV_H2=$2

data_total=0
compr_total=0
count=0

# Extract lines for the device and process each
while read -r line; do
    # Get DATA and TOTAL columns (fields 4 and 6)
    data=$(echo "$line" | awk '{print $4}')
    compr=$(echo "$line" | awk '{print $6}')

    # Convert sizes to MiB (handles M and G)
    data_bytes=$(numfmt --from=iec "$data")
    compr_bytes=$(numfmt --from=iec "$compr")

    data_total=$((data_total + data_bytes))
    compr_total=$((compr_total + compr_bytes))
    count=$((count + 1))
done < <(grep "$DEV_H2" "$RESULT_DIR/zram_usage.txt")

if [ "$count" -eq 0 ]; then
    echo "No entries found for $DEV_H2"
    exit 1
fi

# Calculate averages in MiB
avg_data=$(echo "$data_total / $count / 1048576" | bc -l)
avg_compr=$(echo "$compr_total / $count / 1048576" | bc -l)
avg_ratio=$(echo "$data_total / $compr_total" | bc -l)

# Output as CSV: avg_data_size(MiB),avg_compr_size(MiB),avg_compr_ratio
echo "DATA_SIZE_MB,$avg_data"
echo "COMPR_SIZE_MB,$avg_compr"
echo "RATIO,$avg_ratio"