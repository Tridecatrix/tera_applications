#!/usr/bin/env bash
# filepath: c:\Users\adnan\Desktop\Work\2025\COMP4550_Honours\tera_applications\verify_conf.sh

# Usage message
usage() {
    echo "Usage: $0 [-c path/to/conf.sh]"
    exit 1
}

# Default conf.sh path
CONF_SH="./conf.sh"

# Parse arguments
while getopts ":c:h" opt; do
    case "${opt}" in
        c)
            CONF_SH="${OPTARG}"
            ;;
        h)
            usage
            ;;
        *)
            usage
            ;;
    esac
done

# Source the specified conf.sh
. "$CONF_SH"


error=0

# Check DATA_HDFS directory exists
if [[ "$DATA_HDFS" =~ ^file://(.+) ]]; then
    hdfs_dir="${BASH_REMATCH[1]}"
    if [[ ! -d "$hdfs_dir" ]]; then
        echo "ERROR: DATA_HDFS directory '$hdfs_dir' does not exist."
        error=1
    fi
else
    echo "ERROR: DATA_HDFS is not a local file path."
    error=1
fi

# Check DEV_SHFL and DEV_H2 exist
for dev in "$DEV_SHFL" "$DEV_H2"; do
    if [[ ! -b "/dev/$dev" || ! -e "/dev/$dev" ]]; then
        echo "ERROR: Device '/dev/$dev' does not exist."
        error=1
    fi
done

# Check MNT_SHFL and MNT_H2 exist and are folders
for mnt in "$MNT_SHFL" "$MNT_H2"; do
    if [[ ! -d "$mnt" ]]; then
        echo "ERROR: Mount point '$mnt' does not exist or is not a directory."
        error=1
    fi
done

# Check mount points are on the relevant devices
check_mount_device() {
    local mnt="$1"
    local dev="$2"
    mount_dev=$(findmnt -n -o SOURCE --target "$mnt")
    if [[ "$mount_dev" != "/dev/$dev" ]]; then
        echo "ERROR: Mount point '$mnt' is not on device '/dev/$dev'."
        error=1
    fi
}
check_mount_device "$MNT_SHFL" "$DEV_SHFL"
check_mount_device "$MNT_H2" "$DEV_H2"

# Check H1_SIZE, H2_FILE_SZ, H1_H2_SIZE do not end with 'G'
for val in "${H1_SIZE[@]}" "$H2_FILE_SZ" "${H1_H2_SIZE[@]}"; do
    if [[ "$val" =~ [Gg]$ ]]; then
        echo "ERROR: Value '$val' ends with 'G'. Remove the 'G' suffix."
        error=1
    fi
done

if [[ $error -eq 0 ]]; then
    echo "All configuration checks passed."
else
    echo "One or more configuration checks failed."
    exit 1
fi