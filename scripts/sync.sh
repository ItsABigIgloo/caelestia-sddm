#!/usr/bin/env bash
set -o pipefail

THEME_DIR="/usr/share/sddm/themes/caelestia"
REAL_USER=$(ls /home | grep -v "lost+found" | head -n 1)
REAL_HOME="/home/$REAL_USER"
CAEL_STATE="$REAL_HOME/.local/state/caelestia"

# 1. Sync Colors FIRST
# We do this first so the wallpaper logic can override any hardcoded paths in this file
if [ -f "$CAEL_STATE/theme/sddm-theme.conf" ]; then
    cp -f "$CAEL_STATE/theme/sddm-theme.conf" "$THEME_DIR/theme.conf"
    chmod 644 "$THEME_DIR/theme.conf"
fi

# 2. Sync Wallpaper LAST
if [[ -f "$CAEL_STATE/wallpaper/current" ]]; then
    # Detect extension and handle symlinks
    FILENAME=$(basename "$(readlink -f "$CAEL_STATE/wallpaper/current")")
    EXT="${FILENAME##*.}"
    TARGET="background.$EXT"
    
    # Clean out old backgrounds to prevent collisions
    rm -f "$THEME_DIR/assets/background."*
    
    # Copy and set permissions
    cp -f "$CAEL_STATE/wallpaper/current" "$THEME_DIR/assets/$TARGET"
    chmod 644 "$THEME_DIR/assets/$TARGET"

    # Force the path into theme.conf
    sed -i "s|^background=.*|background=assets/$TARGET|" "$THEME_DIR/theme.conf"
    echo "✓ Synced $TARGET"
fi