#!/bin/bash

# Function to normalize strings (for file naming)
normalize_string() {
    echo "$1" | tr '[:upper:]' '[:lower:]' | tr -cd '[:alnum:]_' | tr ' ' '_'
}

# Function to display color-coded messages
color_output() {
    local color="$1"
    local message="$2"
    case "$color" in
        green) echo -e "\033[0;32m$message\033[0m" ;;
        red) echo -e "\033[0;31m$message\033[0m" ;;
        yellow) echo -e "\033[0;33m$message\033[0m" ;;
        *) echo "$message" ;;
    esac
}

# Function to check if fabric is installed
check_fabric_installed() {
    if ! command -v fabric &> /dev/null; then
        color_output red "Error: 'fabric' command not found. Please install fabric and try again."
        exit 1
    fi
}

# Function to fetch daily tasks for the profession using fabric
fetch_daily_tasks() {
    local profession="$1"
    color_output yellow "Fetching daily tasks for $profession..."
    echo "List all daily tasks working as $profession." | fabric -p ai
}

# Function to analyze tasks and suggest fabric patterns
suggest_patterns() {
    local profession="$1"
    local daily_tasks="$2"
    local output_file="$3"
    
    color_output yellow "Suggesting fabric patterns for $profession..."
    # Use echo to pass the tasks directly into fabric with context
    echo -e "Given the following daily tasks of $profession, analyze each task carefully and suggest fabric patterns that help on each task and explain your suggestions:\n$daily_tasks" | \
        fabric -C suggest_pattern_context.md -sp suggest_pattern | tee -a "$output_file"
}

# Main function to generate the markdown file
generate_md_file() {
    local profession="$1"
    local output_file="$2"
    
    daily_tasks=$(fetch_daily_tasks "$profession")

    if [ -z "$daily_tasks" ]; then
        color_output red "Error: No tasks returned for the profession: $profession."
        exit 1
    fi

    color_output yellow "Writing daily tasks to $output_file..."

    # Write daily tasks to the markdown file
    echo -e "### Daily tasks of $profession:\n" > "$output_file"
    echo "$daily_tasks" >> "$output_file"
    echo -e "\n---\n" >> "$output_file"
    cat "$output_file"

    # Suggest patterns and append to the file
    suggest_patterns "$profession" "$daily_tasks" "$output_file"

    color_output green "Pattern suggestions have been saved to: $output_file"
}

# Default values
DEFAULT_PROFESSION="Software Engineer"
DEFAULT_OUTPUT_FILE="software_engineer_patterns.md"

# Parse arguments
PROFESSION="${1:-$DEFAULT_PROFESSION}"
NORMALIZED_PROFESSION=$(normalize_string "$PROFESSION")
OUTPUT_FILE="${2:-${NORMALIZED_PROFESSION}_patterns.md}"

# Check if fabric is installed
check_fabric_installed

# Call the main function to generate the markdown file
generate_md_file "$PROFESSION" "$OUTPUT_FILE"

