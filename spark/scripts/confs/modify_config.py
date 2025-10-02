#!/usr/bin/env python3

"""
Script to create copies of configuration files with modified parameters.
Supports both single-line and multi-line parameters.

Usage:
    python modify_config.py <source_config> <new_config> [options]

Options:
    -p, --param <name>=<value>    Set a parameter (can be used multiple times)
    -f, --from-file <file>        Read parameter changes from a file
    -l, --list                    List all available parameters
    --force                       Force overwrite without prompting
    -h, --help                    Show this help message

Examples:
    # Single parameter change
    python modify_config.py conf-ssd.sh conf-large.sh -p DATA_SIZE=large
    
    # Multiple parameter changes
    python modify_config.py conf-ssd.sh conf-custom.sh -p DATA_SIZE=large -p H2_FILE_SZ=400
    
    # Multi-line parameter (use quotes for command line)
    python modify_config.py conf-ssd.sh conf-benchmarks.sh -p 'BENCHMARKS=(
        "PageRank"
        "LinearRegression"
    )'
    
    # Single-line format for multi-line parameters
    python modify_config.py conf-ssd.sh conf-benchmarks.sh -p 'BENCHMARKS=( "PageRank" "LinearRegression" )'
    
    # From parameter file (only single-line format supported in files)
    python modify_config.py conf-ssd.sh conf-from-file.sh -f params.txt
    
    # Force overwrite without prompting
    python modify_config.py conf-ssd.sh conf-large.sh -p DATA_SIZE=large --force
    
    # List all parameters
    python modify_config.py conf-ssd.sh -l

Multi-line Parameter Support:
    The script can handle multi-line bash array parameters like:
    
    BENCHMARKS=(
        "ConnectedComponent"
        "PageRank"
    )
    
    You can replace them with either:
    - Single-line format: BENCHMARKS=( "PageRank" "LinearRegression" )
    - Multi-line format: BENCHMARKS=(
        "PageRank"
        "LinearRegression"
    )
    
    Note: Parameter files only support single-line format.
"""

import argparse
import re
import shutil
import sys
from pathlib import Path


def parse_config_file(config_path):
    """Parse the config file and extract all parameters."""
    parameters = {}
    
    with open(config_path, 'r') as f:
        lines = f.readlines()
    
    i = 0
    while i < len(lines):
        line = lines[i].strip()
        # Match lines that look like PARAMETER=value
        match = re.match(r'^([A-Z_][A-Z0-9_]*)=(.*)$', line)
        if match:
            param_name = match.group(1)
            param_value = match.group(2)
            start_line = i + 1
            
            # Check if this is a multi-line parameter (starts with opening parenthesis)
            if param_value.strip().startswith('(') and not param_value.strip().endswith(')'):
                # This is a multi-line parameter, collect all lines until closing parenthesis
                full_value = [param_value]
                i += 1
                while i < len(lines):
                    next_line = lines[i].rstrip()
                    full_value.append(next_line)
                    if next_line.strip().endswith(')'):
                        break
                    i += 1
                param_value = '\n'.join(full_value)
                end_line = i + 1
            else:
                end_line = start_line
            
            parameters[param_name] = {
                'value': param_value,
                'start_line': start_line,
                'end_line': end_line,
                'is_multiline': start_line != end_line
            }
        i += 1
    
    return parameters


def modify_config(source_path, target_path, param_changes):
    """Create a modified copy of the config file."""
    # Read the original file
    with open(source_path, 'r') as f:
        lines = f.readlines()
    
    # Parse the config to understand multi-line parameters
    config_params = parse_config_file(source_path)
    
    # Apply changes
    changes_made = {}
    lines_to_skip = set()  # Track lines that are part of multi-line parameters we're replacing
    
    for param_name, new_value in param_changes.items():
        if param_name in config_params:
            param_info = config_params[param_name]
            old_value = param_info['value']
            start_line = param_info['start_line'] - 1  # Convert to 0-based indexing
            end_line = param_info['end_line'] - 1
            
            if param_info['is_multiline']:
                # For multi-line parameters, replace all lines from start to end
                # Mark intermediate lines for skipping
                for line_idx in range(start_line + 1, end_line + 1):
                    lines_to_skip.add(line_idx)
                
                # Replace the first line with the complete new value
                param_name_from_line = lines[start_line].split('=', 1)[0]
                lines[start_line] = f"{param_name_from_line}={new_value}\n"
            else:
                # Single line parameter
                param_name_from_line = lines[start_line].split('=', 1)[0]
                lines[start_line] = f"{param_name_from_line}={new_value}\n"
            
            changes_made[param_name] = {
                'old': old_value,
                'new': new_value,
                'start_line': param_info['start_line'],
                'end_line': param_info['end_line'],
                'is_multiline': param_info['is_multiline']
            }
        else:
            print(f"Warning: Parameter '{param_name}' not found in config file")
    
    # Create the final lines list, skipping lines that were part of replaced multi-line parameters
    final_lines = []
    for i, line in enumerate(lines):
        if i not in lines_to_skip:
            final_lines.append(line)
    
    # Write the modified file
    with open(target_path, 'w') as f:
        f.writelines(final_lines)
    
    return changes_made


def read_params_from_file(param_file):
    """Read parameter changes from a file."""
    params = {}
    with open(param_file, 'r') as f:
        for line_num, line in enumerate(f, 1):
            line = line.strip()
            if line and not line.startswith('#'):
                if '=' in line:
                    key, value = line.split('=', 1)
                    params[key.strip()] = value.strip()
                else:
                    print(f"Warning: Invalid format on line {line_num}: {line}")
    return params


def main():
    parser = argparse.ArgumentParser(
        description="Create copies of configuration files with modified parameters",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__
    )
    
    parser.add_argument('source_config', help='Source configuration file')
    parser.add_argument('new_config', nargs='?', help='New configuration file')
    parser.add_argument('-p', '--param', action='append', default=[],
                       help='Parameter to change (format: NAME=VALUE)')
    parser.add_argument('-f', '--from-file', 
                       help='Read parameter changes from file')
    parser.add_argument('-l', '--list', action='store_true',
                       help='List all available parameters')
    parser.add_argument('--force', action='store_true',
                       help='Force overwrite without prompting')
    
    args = parser.parse_args()
    
    # Check if source file exists
    source_path = Path(args.source_config)
    if not source_path.exists():
        print(f"Error: Source config file '{source_path}' does not exist")
        return 1
    
    # Parse the source config to get available parameters
    try:
        available_params = parse_config_file(source_path)
    except Exception as e:
        print(f"Error reading source config: {e}")
        return 1
    
    # If list option is specified, show available parameters
    if args.list:
        print(f"Available parameters in '{source_path}':")
        print("-" * 50)
        for param_name, param_info in sorted(available_params.items()):
            print(f"{param_name:20} = {param_info['value']}")
        return 0
    
    # Check if target config is specified
    if not args.new_config:
        print("Error: Target config file must be specified when not using --list")
        return 1
    
    target_path = Path(args.new_config)
    
    # Collect parameter changes
    param_changes = {}
    
    # From command line arguments
    for param_str in args.param:
        if '=' not in param_str:
            print(f"Error: Invalid parameter format '{param_str}'. Use NAME=VALUE")
            return 1
        name, value = param_str.split('=', 1)
        param_changes[name.strip()] = value.strip()
    
    # From file
    if args.from_file:
        try:
            file_params = read_params_from_file(args.from_file)
            param_changes.update(file_params)
        except Exception as e:
            print(f"Error reading parameter file: {e}")
            return 1
    
    # Check if any changes were specified
    if not param_changes:
        print("Error: No parameter changes specified")
        return 1
    
    # Validate parameters exist
    invalid_params = [p for p in param_changes.keys() if p not in available_params]
    if invalid_params:
        print("Error: The following parameters are not valid:")
        for param in invalid_params:
            print(f"  {param}")
        print("\nAvailable parameters:")
        for param in sorted(available_params.keys()):
            print(f"  {param}")
        return 1
    
    # Check if target file exists
    if target_path.exists():
        if not args.force:
            response = input(f"Target file '{target_path}' exists. Overwrite? (y/n): ")
            if response.lower() != 'y':
                print("Operation cancelled")
                return 0
        else:
            print(f"Force overwriting existing file '{target_path}'")
    
    # Create the modified config
    try:
        changes_made = modify_config(source_path, target_path, param_changes)
        
        print(f"Successfully created '{target_path}'")
        print("\nChanges made:")
        print("-" * 50)
        for param_name, change_info in changes_made.items():
            print(f"{param_name}:")
            if change_info['is_multiline']:
                print(f"  Old (multiline):")
                for line in change_info['old'].split('\n'):
                    print(f"    {line}")
                print(f"  New: {change_info['new']}")
                print(f"  Lines: {change_info['start_line']}-{change_info['end_line']}")
            else:
                print(f"  Old: {change_info['old']}")
                print(f"  New: {change_info['new']}")
                print(f"  Line: {change_info['start_line']}")
            print()
        
        return 0
        
    except Exception as e:
        print(f"Error creating modified config: {e}")
        return 1


if __name__ == '__main__':
    sys.exit(main())