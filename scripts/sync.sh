#!/usr/bin/env bash
# No set -u here so we can handle empty paths gracefully
set -o pipefail

THEME_DIR="/usr/share/sddm/themes/caelestia"

# Find the home directory of the person who actually uses this PC
# This looks for the first non-root user folder in /home
REAL_USER=$(ls /home | grep -v "lost+found" | head -n 1)
REAL_HOME="/home/$REAL_USER"
CAEL_STATE="$REAL_HOME/.local/state/caelestia"

echo "Syncing Caelestia assets for user: $REAL_USER"

# Sync Wallpaper
if [[ -f "$CAEL_STATE/wallpaper/current" ]]; then
    # Detect the actual extension (e.g., jpg, mp4, gif)
    # If no extension is found, default to png
    FILENAME=$(basename "$(readlink -f "$CAEL_STATE/wallpaper/current")")
    EXT="${FILENAME##*.}"
    
    # Sync the file with its original extension
    cp -f "$CAEL_STATE/wallpaper/current" "$THEME_DIR/assets/background.$EXT"
    chmod 644 "$THEME_DIR/assets/background.$EXT"

    # Update theme.conf so Main.qml knows which file to load
    sed -i "s|background=.*|background=assets/background.$EXT|" "$THEME_DIR/theme.conf"
fi

# Sync Colors
if [ -f "$CAEL_STATE/theme/sddm-theme.conf" ]; then
    cp -f "$CAEL_STATE/theme/sddm-theme.conf" "$THEME_DIR/theme.conf"
    chmod 644 "$THEME_DIR/theme.conf"
fi