DAILY_TASKS=$(echo "List all daily tasks working as software engineer." | fabric -p ai)
OUTPUT_FILE="software_engineer_patterns.md"
echo -e "### Daily tasks of software engineer:\n$DAILY_TASKS\n" > "$OUTPUT_FILE"
echo -e "Given the following daily tasks of software engineer, analyze each task carefully and suggest fabric patterns that help on each task and explain your suggestions:\n$DAILY_TASKS" | fabric -C suggest_pattern_context.md -sp suggest_pattern | tee -a "$OUTPUT_FILE"

