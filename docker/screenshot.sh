#!/bin/bash
# Take a screenshot of the game window
# Usage: screenshot.sh [output_filename]

SCREENSHOT_DIR="/home/druser/screenshots"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
FILENAME="${1:-screenshot_${TIMESTAMP}.png}"

# Ensure directory exists
mkdir -p "$SCREENSHOT_DIR"

# Take screenshot using scrot
DISPLAY=:99 scrot -o "$SCREENSHOT_DIR/$FILENAME"

if [ $? -eq 0 ]; then
    echo "$SCREENSHOT_DIR/$FILENAME"
else
    echo "ERROR: Failed to take screenshot" >&2
    exit 1
fi
