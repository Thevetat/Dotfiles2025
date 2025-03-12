#!/bin/bash
LOG_FILE="/tmp/yabai_space_management.log"
# Function to log messages
log_message() {
    echo "$(date): $1" >>"$LOG_FILE" 2>/dev/null || echo "Failed to write to log file"
}
# Create log file if it doesn't exist
touch "$LOG_FILE" 2>/dev/null || {
    echo "Cannot create log file. Check permissions or path."
    exit 1
}
log_message "Starting Yabai space management script"
DESIRED_SPACES_PER_DISPLAY=4
CURRENT_SPACES="$(yabai -m query --displays | jq -r '.[].spaces[]' | tr '\n' ' ')"
DELTA=0
log_message "Current spaces: $CURRENT_SPACES"
# Get the number of displays
DISPLAY_COUNT=$(yabai -m query --displays | jq length)
log_message "Number of displays: $DISPLAY_COUNT"
for ((display = 1; display <= DISPLAY_COUNT; display++)); do
    log_message "Processing display $display"
    # Get spaces for current display
    DISPLAY_SPACES=$(yabai -m query --displays --display $display | jq -r '.spaces[]' | tr '\n' ' ')
    log_message "Spaces on display $display: $DISPLAY_SPACES"
    EXISTING_SPACE_COUNT=$(echo "$DISPLAY_SPACES" | wc -w | tr -d '[:space:]')
    MISSING_SPACES=$((DESIRED_SPACES_PER_DISPLAY - EXISTING_SPACE_COUNT))
    log_message "Existing space count: $EXISTING_SPACE_COUNT"
    log_message "Missing spaces: $MISSING_SPACES"
    if [ "$MISSING_SPACES" -gt 0 ]; then
        log_message "Creating $MISSING_SPACES new spaces"
        for ((i = 1; i <= MISSING_SPACES; i++)); do
            log_message "Creating new space"
            yabai -m space --create || log_message "Failed to create space"
        done
    elif [ "$MISSING_SPACES" -lt 0 ]; then
        log_message "Removing $((0 - MISSING_SPACES)) spaces"
        for ((i = 1; i <= (0 - MISSING_SPACES); i++)); do
            LAST_SPACE=$(yabai -m query --spaces --display $display | jq '.[-1].index')
            log_message "Removing space $LAST_SPACE"
            yabai -m space --destroy "$LAST_SPACE" || log_message "Failed to destroy space $LAST_SPACE"
        done
    fi
    DELTA=$((DELTA + MISSING_SPACES))
    log_message "Delta: $DELTA"
    log_message "---"
done

# Ensure we have at least 8 spaces total for our rules to work
TOTAL_SPACES=$(yabai -m query --spaces | jq 'length')
log_message "Total spaces after initial setup: $TOTAL_SPACES"

if [ "$TOTAL_SPACES" -lt 8 ]; then
    SPACES_TO_ADD=$((8 - TOTAL_SPACES))
    log_message "Adding $SPACES_TO_ADD more spaces to reach 8 total"

    for ((i = 1; i <= SPACES_TO_ADD; i++)); do
        yabai -m space --create || log_message "Failed to create additional space"
    done
fi

# Move specific applications to designated spaces
log_message "Moving applications to their designated spaces"

# Try to move Spotify to space 8
SPOTIFY_WINDOWS=$(yabai -m query --windows | jq '.[] | select(.app=="Spotify") | .id')
if [ -n "$SPOTIFY_WINDOWS" ]; then
    log_message "Found Spotify windows: $SPOTIFY_WINDOWS"
    for window_id in $SPOTIFY_WINDOWS; do
        log_message "Moving Spotify window $window_id to space 8"
        yabai -m window $window_id --space 8 || log_message "Failed to move Spotify window $window_id"
    done
else
    log_message "No Spotify windows found"
fi

# Move Discord to space 7
DISCORD_WINDOWS=$(yabai -m query --windows | jq '.[] | select(.app=="Discord") | .id')
if [ -n "$DISCORD_WINDOWS" ]; then
    log_message "Found Discord windows: $DISCORD_WINDOWS"
    for window_id in $DISCORD_WINDOWS; do
        log_message "Moving Discord window $window_id to space 7"
        yabai -m window $window_id --space 7 || log_message "Failed to move Discord window $window_id"
    done
else
    log_message "No Discord windows found"
fi

sketchybar --trigger space_change --trigger windows_on_spaces
log_message "Finished Yabai space management script"
