#!/usr/bin/env bash

set -e  # Exit immediately if a command exits with a non-zero status

# Default values
output=""
depth=5
exclude_patterns='\.git|.cache|.obsidian|.DS_Store|node_modules|dist|_build|build|__pycache__|.*\.log|.*\.tmp|.*\.dump|.*\.bak|.*\.dump\.txt'

# Function to display usage
usage() {
    echo "Usage: $0 [-o output_file] [-d depth] [-e exclude_patterns] [directories...]"
    exit 1
}

# Parse command-line options
while getopts ":o:d:e:" opt; do
    case ${opt} in
        o )
            output=$OPTARG
            ;;
        d )
            depth=$OPTARG
            ;;
        e )
            exclude_patterns+="|$(echo "$OPTARG" | tr '[:upper:]' '[:lower:]')"
            ;;
        \? )
            usage
            ;;
    esac
done
shift $((OPTIND -1))

# Initialize directories and output file
directory=$(pwd)
parent_folder=$(basename "$directory")
timestamp=$(date "+%m-%y_%H-%M")
output=${output:-"${parent_folder}_${timestamp}.dump.txt"}

# Ensure the output file is empty initially
: > "$output"

# Function to print a formatted header
print_header() {
    printf "##\n%s\n#\n" "$1" >> "$output"
}

# Function to dump file contents
dump_file_content() {
    local file="$1"
    local extension="${file##*.}"
    local attachment_extensions="png|jpg|jpeg|gif|webp|zip|img|mp4|mp3|pdf|mov|m4a"

    if [[ $attachment_extensions =~ $extension ]]; then
        # Print only the file name for attachments
        print_header "Attachment: $(basename "$file")"
    else
        if [ -r "$file" ]; then  # Check if the file is readable
            print_header "File Name: $(basename "$file")"
            printf '"""\n' >> "$output"
            cat "$file" >> "$output"
            printf '\n"""\n\n##\n' >> "$output"
        else
            echo "Cannot read $file (permissions denied)" >&2
        fi
    fi
}

# Function to dump a 1-level tree view for directories
dump_directory_tree() {
    local dir="$1"
    if [ -r "$dir" ]; then  # Check if the directory is readable
        print_header "Directory Tree: $(basename "$dir")"
        tree -L 1 "$dir" >> "$output" 2>/dev/null || echo "Error listing directory $dir" >> "$output"
        printf "##\n" >> "$output"
    else
        echo "Cannot read directory $dir (permissions denied)" >&2
    fi
}

# Function to cleanup temporary files or other resources
cleanup() {
    # Add any cleanup code here if needed
    :
}

# Trap to handle cleanup on exit
trap 'cleanup' EXIT

# Check for required commands
if ! command -v tree &>/dev/null; then
    echo "Error: 'tree' command not found. Please install it and try again." >&2
    exit 1
fi

# Prepare the output file header
{
    printf "Repository Content Dump\n"
    printf "=======================\n"
    printf "Directory: %s\n" "$directory"
    printf "Generated: %s\n\n" "$(date)"
} > "$output"

# Parse user-supplied excluded directories
user_exclude_patterns=()
for dir in "$@"; do
    user_exclude_patterns+=("$dir")
done

if [ ${#user_exclude_patterns[@]} -gt 0 ]; then
    exclude_patterns+="|$(IFS='|'; echo "${user_exclude_patterns[*]}" | tr '[:upper:]' '[:lower:]')"
fi

# Function to check if a file or directory should be excluded
should_exclude() {
    local path="$1"
    [[ "$path" =~ $exclude_patterns ]]
}

# Function to process directories and files
process_path() {
    local path="$1"
    local current_depth="$2"

    if should_exclude "$path"; then
        return
    fi

    if [ -d "$path" ]; then
        dump_directory_tree "$path"
        if [ -n "$depth" ] && [ "$current_depth" -lt "$depth" ]; then
            find "$path" -maxdepth 1 -mindepth 1 | while IFS= read -r subpath; do
                process_path "$subpath" $((current_depth + 1))
            done
        fi
    elif [ -f "$path" ]; then
        dump_file_content "$path"
    fi
}

# Process each directory or file provided by the user
if [ $# -eq 0 ]; then
    process_path "$directory" 0
else
    for dir in "$@"; do
        process_path "$dir" 0
    done
fi

echo "Dump completed. Output saved to $output"
