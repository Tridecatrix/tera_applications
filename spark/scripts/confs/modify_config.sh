#!/usr/bin/env bash

###################################################
#
# file: modify_config.sh
#
# Script to create a copy of a config file with
# specific parameters modified
#
# Usage: ./modify_config.sh <source_config> <new_config> <parameter> <new_value>
# Example: ./modify_config.sh conf-ssd.sh conf-ssd-modified.sh DATA_SIZE large
#
###################################################

# Function to display usage
usage() {
    echo "Usage: $0 [OPTIONS] <source_config> <new_config> <parameter> <new_value>"
    echo ""
    echo "Options:"
    echo "  -f, --force    - Force overwrite without prompting"
    echo ""
    echo "Arguments:"
    echo "  source_config  - Path to the source configuration file"
    echo "  new_config     - Path for the new configuration file"
    echo "  parameter      - Parameter name to modify (e.g., DATA_SIZE, H2_FILE_SZ)"
    echo "  new_value      - New value for the parameter"
    echo ""
    echo "Examples:"
    echo "  $0 conf-ssd.sh conf-large.sh DATA_SIZE large"
    echo "  $0 conf-ssd.sh conf-400gb.sh H2_FILE_SZ 400"
    echo "  $0 -f conf-ssd.sh conf-4cores.sh EXEC_CORES '( 4 )'"
    echo "  $0 --force conf-ssd.sh conf-pagerank.sh BENCHMARKS '( \"PageRank\" )'"
    exit 1
}

# Parse command line options
FORCE_OVERWRITE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -f|--force)
            FORCE_OVERWRITE=true
            shift
            ;;
        -*)
            echo "Error: Unknown option $1"
            usage
            ;;
        *)
            break
            ;;
    esac
done

# Check if correct number of arguments provided
if [ $# -ne 4 ]; then
    echo "Error: Incorrect number of arguments"
    usage
fi

SOURCE_CONFIG="$1"
NEW_CONFIG="$2"
PARAMETER="$3"
NEW_VALUE="$4"

# Check if source config file exists
if [ ! -f "$SOURCE_CONFIG" ]; then
    echo "Error: Source config file '$SOURCE_CONFIG' does not exist"
    exit 1
fi

# Check if new config file already exists
if [ -f "$NEW_CONFIG" ]; then
    if [ "$FORCE_OVERWRITE" = false ]; then
        echo "Warning: Target config file '$NEW_CONFIG' already exists"
        read -p "Do you want to overwrite it? (y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Operation cancelled"
            exit 1
        fi
    else
        echo "Force overwriting existing file '$NEW_CONFIG'"
    fi
fi

# Create a copy of the source config
cp "$SOURCE_CONFIG" "$NEW_CONFIG"

# Check if the parameter exists in the file
if ! grep -q "^${PARAMETER}=" "$NEW_CONFIG"; then
    echo "Warning: Parameter '$PARAMETER' not found in the config file"
    echo "Available parameters:"
    grep "^[A-Z_]*=" "$NEW_CONFIG" | cut -d'=' -f1 | sort
    exit 1
fi

# Escape special characters in the new value for sed
ESCAPED_VALUE=$(printf '%s\n' "$NEW_VALUE" | sed 's/[[\.*^$()+?{|]/\\&/g')

# Replace the parameter value
sed -i "s/^${PARAMETER}=.*/${PARAMETER}=${ESCAPED_VALUE}/" "$NEW_CONFIG"

# Verify the change was made
echo "Configuration file '$NEW_CONFIG' created successfully"
echo "Modified parameter:"
grep "^${PARAMETER}=" "$NEW_CONFIG"

# Optional: Show diff between original and new file
echo ""
echo "Differences between original and new config:"
diff "$SOURCE_CONFIG" "$NEW_CONFIG" || true