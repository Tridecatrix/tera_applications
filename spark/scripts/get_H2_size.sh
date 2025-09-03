BENCHMARKS=(
    "ConnectedComponent"
    "LinearRegression"
    "LogisticRegression"
    "PageRank"
    "ShortestPaths"
    # "SVDPlusPlus"
    # "SVM"
    # "TriangleCount"
)

for b in "${BENCHMARKS[@]}"; do
    FILE="_2025-09-03-time-13-41-54/$b/run0/conf0/teraHeap.txt"
    VALUE=$(grep "TOTAL_OBJECTS_SIZE" "$FILE" | awk 'max<$5{max=$5} END{print max}')
    echo "$b: $(echo "scale=2; $VALUE / 1024.0 / 1024.0 / 1024.0" | bc -l) GB"
done