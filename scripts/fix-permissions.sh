#!/usr/bin/env bash
set -euo pipefail

if [ "$(id -u)" -eq 0 ] && [ -z "${SUDO_USER:-}" ]; then
    echo "ERROR: Do not run this as root directly. Run as: sudo $0" >&2
    exit 1
fi

REAL_USER="${SUDO_USER:-$(whoami)}"
REAL_HOME=$(getent passwd "$REAL_USER" | cut -d: -f6)

for dir in \
    "$REAL_HOME/.local/state/caelestia" \
    "$REAL_HOME/.config/caelestia" \
    "$REAL_HOME/.local/share/caelestia"; do
    if [ -d "$dir" ]; then
        chown -R "$REAL_USER:$REAL_USER" "$dir"
        echo "✓ Fixed ownership on $dir"
    fi
done
