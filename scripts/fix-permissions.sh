#!/usr/bin/env bash
set -euo pipefail

# This script should only be run as the real user.
if [ "$(id -u)" -eq 0 ]; then
    echo "ERROR: Do not run this script with sudo. Run it normally." >&2
    exit 1
fi

REAL_USER="$(whoami)"
REAL_HOME=$(getent passwd "$REAL_USER" | cut -d: -f6)

TARGETS=(
    "$REAL_HOME/.config/caelestia"
    "$REAL_HOME/.local/state/caelestia"
    "$REAL_HOME/.local/share/caelestia"
)

echo "This script requires sudo to fix ownership of Caelestia files."
sudo -v

for dir in "${TARGETS[@]}"; do
    if [ -d "$dir" ]; then
        sudo chown -hR "$REAL_USER:$REAL_USER" "$dir"

        # Do not follow symlinks while normalizing permissions.
        find -P "$dir" -xdev -type d -exec chmod u+rwx,go-rwx {} +
        find -P "$dir" -xdev -type f -exec chmod u+rw,go-rwx {} +

        echo "✓ Fixed ownership and permissions on $dir"
    fi
done
