#!/bin/bash

# Read the JSON input from stdin
INPUT=$(cat)

# Extract the transcript path
TRANSCRIPT_PATH=$(echo "$INPUT" | jq -r '.transcript_path')
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id')

# Copy to a readable location with timestamp
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTPUT_FILE="./claude-conversation-${SESSION_ID}-${TIMESTAMP}.jsonl"

cp "$TRANSCRIPT_PATH" "$OUTPUT_FILE"

echo "Conversation exported to: $OUTPUT_FILE"
exit 0
