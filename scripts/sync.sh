#!/usr/bin/env bash
set -o pipefail

THEME_DIR="/usr/share/sddm/themes/caelestia"
REAL_USER=${SUDO_USER:-$(ls /home | grep -v "lost+found" | head -n 1)}
REAL_HOME="/home/$REAL_USER"
CAEL_STATE="$REAL_HOME/.local/state/caelestia"

# 1. Generate colors from the current Caelestia scheme settings FIRST
if [ "$1" = "--posthook" ]; then
    : # Skip color generation when run as posthook (--posthook)
    echo "✓ Running as posthook, skipping color generation"
elif command -v caelestia &>/dev/null; then
    export HOME="$REAL_HOME" XDG_CONFIG_HOME="$REAL_HOME/.config" XDG_DATA_HOME="$REAL_HOME/.local/share" XDG_STATE_HOME="$REAL_HOME/.local/state"
    mapfile -t SCHEME < <(caelestia scheme get --name --mode --variant 2>/dev/null)
    NAME="${SCHEME[0]}"
    MODE="${SCHEME[1]}"
    VARIANT="${SCHEME[2]}"
    if [ -n "$NAME" ] && [ -n "$MODE" ] && [ -n "$VARIANT" ]; then
        caelestia scheme set --name "$NAME" --mode "$MODE" --variant "$VARIANT" 2>/dev/null
        echo "✓ Generated colors for scheme: $NAME/$MODE/$VARIANT"
    else
        echo "Could not read Caelestia scheme, skipping color generation"
    fi
else
    echo "Caelestia CLI not found, skipping color generation"
fi

# 2. Sync avatar files into theme assets so sddm can safely access them without permission issues.
if [ -f "$REAL_HOME/.face.icon" ]; then
    cp -f "$REAL_HOME/.face.icon" "$THEME_DIR/assets/avatar.face.icon"
    chmod 644 "$THEME_DIR/assets/avatar.face.icon"
    echo "✓ Synced avatar.face.icon"
else
    rm -f "$THEME_DIR/assets/avatar.face.icon"
fi

if [ -f "$REAL_HOME/.face" ]; then
    cp -f "$REAL_HOME/.face" "$THEME_DIR/assets/avatar.face"
    chmod 644 "$THEME_DIR/assets/avatar.face"
    echo "✓ Synced avatar.face"
else
    rm -f "$THEME_DIR/assets/avatar.face"
fi

# 3. Sync Colors
if [ -f "$CAEL_STATE/theme/sddm-theme.conf" ]; then
    cp -f "$CAEL_STATE/theme/sddm-theme.conf" "$THEME_DIR/theme.conf"
    chmod 644 "$THEME_DIR/theme.conf"
fi

# 4. Sync Wallpaper LAST
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
    echo "✓ Synced $TARGET"
fi
