#!/bin/bash

# Check if directory is passed as an argument
if [ -z "$1" ]; then
    echo "Usage: $0 <directory>"
    exit 1
fi

# Set the base directory from the argument
BASE_DIR=$1

# Initialize the JSON content
JSON_CONTENT="[\n"
TXT_CONTENT=""

# Iterate over each subdirectory in the base directory
for SUBDIR in "$BASE_DIR"/*/; do
    # Check if it is a directory
    if [ -d "$SUBDIR" ]; then
        # Set the output markdown file for the subdirectory
        OUTPUT_FILE="${SUBDIR%/}/combined.txt"

        # Clear the contents of the output file if it exists
        > "$OUTPUT_FILE"

        # Find all markdown files in the subdirectory and append to the combined file
        for FILE in "$SUBDIR"*.md; do
            if [ -f "$FILE" ]; then
                echo "Processing $FILE"
                
                # Add pattern and file name as a header before the content
                FILE_NAME=$(basename "$FILE")
                PATTERN_NAME=$(basename "$SUBDIR")
                echo -e "\n#$PATTERN_NAME: $FILE_NAME\n" >> "$OUTPUT_FILE"

                # Add the file's content to the output file
                cat "$FILE" >> "$OUTPUT_FILE"
                
                # Optionally add a newline between files
                echo -e "\n" >> "$OUTPUT_FILE"
            fi
        done
        echo "Combined Markdown file created at: $OUTPUT_FILE"
        # Use the subdirectory name as the 'name' field
        SUBDIR_NAME=$(basename "$SUBDIR")
        JSON_CONTENT+="{\n"
        JSON_CONTENT+="  \"name\": \"$SUBDIR_NAME\",\n"
        JSON_CONTENT+="  \"description\": \""
        # Summarize the pattern
        DESCRIPTION=$(cat $OUTPUT_FILE | fabric -p summarize_prompt | tr '\n' ' ')
        # Add description content to JSON, trimming the final newline
        JSON_CONTENT+="${DESCRIPTION%\\n}\"\n"
         # Close the JSON structure
        JSON_CONTENT+="},"
        # Add name and description txt
        TXT_CONTENT+="$SUBDIR_NAME: $DESCRIPTION\n"
        sleep 5
    fi
done
JSON_CONTENT+="]\n"
# Write the content to the output file
echo -e "$JSON_CONTENT" > "patterns.json"
echo -e "$TXT_CONTENT" > "patterns.txt"

echo "patterns.json and patterns.txt file created"