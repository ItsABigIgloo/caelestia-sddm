#!/usr/bin/env bash
set -euo pipefail

# Prevent running with sudo - the script uses sudo internally for some commands
if [ "$(id -u)" -eq 0 ]; then
    echo "ERROR: Do not run this script with sudo. Run it normally." >&2
    exit 1
fi

REAL_USER="${SUDO_USER:-$(whoami)}"
REAL_HOME=$(getent passwd "$REAL_USER" | cut -d: -f6)

FACE_FILE="$REAL_HOME/.face"
FACE_ICON_FILE="$REAL_HOME/.face.icon"
if [ ! -f "$FACE_FILE" ]; then
    echo "✗ Missing $FACE_FILE — create .face first, then run this script again." >&2
    exit 1
fi

sudo chown "$REAL_USER:$REAL_USER" "$FACE_FILE"
chmod 644 "$FACE_FILE"
echo "✓ Fixed ownership and permissions on $FACE_FILE"

if [ -L "$FACE_ICON_FILE" ]; then
    link_target="$(readlink "$FACE_ICON_FILE")"
    if [ "$link_target" != ".face" ] && [ "$link_target" != "$FACE_FILE" ]; then
        rm -f "$FACE_ICON_FILE"
        ln -s .face "$FACE_ICON_FILE"
        echo "✓ Replaced symlink $FACE_ICON_FILE -> .face"
    fi
elif [ -e "$FACE_ICON_FILE" ]; then
    rm -f "$FACE_ICON_FILE"
    ln -s .face "$FACE_ICON_FILE"
    echo "✓ Removed old file and created $FACE_ICON_FILE -> .face"
else
    ln -s .face "$FACE_ICON_FILE"
    echo "✓ Created $FACE_ICON_FILE -> .face"
fi

sudo chown -h "$REAL_USER:$REAL_USER" "$FACE_ICON_FILE"

if [ -e "$FACE_ICON_FILE" ] && [ ! -L "$FACE_ICON_FILE" ]; then
    chmod 644 "$FACE_ICON_FILE"
fi
