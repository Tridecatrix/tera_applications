THTXT=$1 # teraheap.txt

# Note: values in teraheap.txt are in milliseconds, we convert to seconds here by dividing by 1000.0

H1_CT_TIME=$(grep "H1_CT_TIME" $THTXT | awk '{print $5}' | awk '{ sum += $1 } END {printf "%.6f", sum/1000.0 }')        
H2_CT_TIME=$(grep "H2_CT_TIME" $THTXT | awk '{print $5}' | awk '{ sum += $1 } END {printf "%.6f", sum/1000.0 }')        
H1_MARKING_PHASE=$(grep "H1_MARKING_PHASE" $THTXT | awk '{print $4}' | awk '{ sum += $1 } END {printf "%.6f", sum/1000.0 }')
H2_SCAVENGE=$(grep "H2_SCAVENGE" $THTXT | awk '{print $4}' | awk '{ sum += $1 } END {printf "%.6f", sum/1000.0 }')
H2_MARKING_BWD_REF=$(grep "H2_MARKING_BWD_REF" $THTXT | awk '{print $4}' | awk '{ sum += $1 } END {printf "%.6f", sum/1000.0 }')
H1_SUMMARY_PHASE=$(grep "H1_SUMMARY_PHASE" $THTXT | awk '{print $4}' | awk '{ sum += $1 } END {printf "%.6f", sum/1000.0 }')
H2_ADJUST_BWD_REF=$(grep "H2_ADJUST_BWD_REF" $THTXT | awk '{print $4}' | awk '{ sum += $1 } END {printf "%.6f", sum/1000.0 }')
H2_PRECOMPACT=$(grep "H2_PRECOMPACT" $THTXT | awk '{print $4}' | awk '{ sum += $1 } END {printf "%.6f", sum/1000.0 }')
H1_ADJUST_ROOTS=$(grep "H1_ADJUST_ROOTS" $THTXT | awk '{print $4}' | awk '{ sum += $1 } END {printf "%.6f", sum/1000.0 }')
H1_COMPACT=$(grep "H1_COMPACT" $THTXT | awk '{print $4}' | awk '{ sum += $1 } END {printf "%.6f", sum/1000.0 }')
H2_COMPACT_PHASE=$(grep "H2_COMPACT_PHASE" $THTXT | awk '{print $4}' | awk '{ sum += $1 } END {printf "%.6f", sum/1000.0 }')
H2_CLEAR_FWD_TABLE=$(grep "H2_CLEAR_FWD_TABLE" $THTXT | awk '{print $4}' | awk '{ sum += $1 } END {printf "%.6f", sum/1000.0 }')
MALLOC=$(grep "MALLOC" $THTXT | awk '{print $4}' | awk '{ sum += $1 } END {printf "%.6f", sum/1000.0 }')

echo "H1_CT_TIME,${H1_CT_TIME}"
echo "H2_CT_TIME,${H2_CT_TIME}"
echo "H1_MARKING_PHASE,${H1_MARKING_PHASE}"
echo "H2_SCAVENGE,${H2_SCAVENGE}"
echo "H2_MARKING_BWD_REF,${H2_MARKING_BWD_REF}"
echo "H1_SUMMARY_PHASE,${H1_SUMMARY_PHASE}"
echo "H2_ADJUST_BWD_REF,${H2_ADJUST_BWD_REF}"
echo "H2_PRECOMPACT,${H2_PRECOMPACT}"
echo "H1_ADJUST_ROOTS,${H1_ADJUST_ROOTS}"
echo "H1_COMPACT,${H1_COMPACT}"
echo "H2_COMPACT_PHASE,${H2_COMPACT_PHASE}"
echo "H2_CLEAR_FWD_TABLE,${H2_CLEAR_FWD_TABLE}"
echo "MALLOC,${MALLOC}"