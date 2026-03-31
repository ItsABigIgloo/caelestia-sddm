#!/usr/bin/env bash
set -euo pipefail

TARGET_USER="${1:-${SUDO_USER:-$USER}}"

if ! id "$TARGET_USER" >/dev/null 2>&1; then
    echo "[FAIL] User not found: $TARGET_USER"
    exit 1
fi

TARGET_HOME="$(getent passwd "$TARGET_USER" | cut -d: -f6)"
if [ -z "$TARGET_HOME" ] || [ ! -d "$TARGET_HOME" ]; then
    echo "[FAIL] Could not resolve home directory for $TARGET_USER"
    exit 1
fi

FACE_FILE="$TARGET_HOME/.face"
FACE_ICON_FILE="$TARGET_HOME/.face.icon"
BACKUP_SUFFIX="$(date +%Y%m%d-%H%M%S)"

is_root() {
    [ "${EUID:-$(id -u)}" -eq 0 ]
}

ensure_owner() {
    local path="$1"
    if is_root; then
        chown "$TARGET_USER:$TARGET_USER" "$path"
    else
        local owner
        owner="$(stat -c '%U' "$path")"
        if [ "$owner" != "$TARGET_USER" ]; then
            echo "[FAIL] $path is owned by $owner (expected $TARGET_USER). Re-run with sudo."
            exit 1
        fi
    fi
}

echo "=== Fixing avatar files for $TARGET_USER ==="

if [ ! -f "$FACE_FILE" ]; then
    echo "[FAIL] Missing $FACE_FILE"
    echo "Create .face first, then run this script again."
    exit 1
fi

ensure_owner "$FACE_FILE"
chmod 644 "$FACE_FILE"
echo "[OK] Fixed ownership and permissions on $FACE_FILE"

if [ -L "$FACE_ICON_FILE" ]; then
    link_target="$(readlink "$FACE_ICON_FILE")"
    if [ "$link_target" = ".face" ] || [ "$link_target" = "$FACE_FILE" ]; then
        echo "[OK] $FACE_ICON_FILE already points to .face"
    else
        mv "$FACE_ICON_FILE" "${FACE_ICON_FILE}.backup-${BACKUP_SUFFIX}"
        ln -s .face "$FACE_ICON_FILE"
        echo "[OK] Replaced old symlink target and pointed $FACE_ICON_FILE -> .face"
    fi
elif [ -e "$FACE_ICON_FILE" ]; then
    mv "$FACE_ICON_FILE" "${FACE_ICON_FILE}.backup-${BACKUP_SUFFIX}"
    ln -s .face "$FACE_ICON_FILE"
    echo "[OK] Backed up old file and created $FACE_ICON_FILE -> .face"
else
    ln -s .face "$FACE_ICON_FILE"
    echo "[OK] Created $FACE_ICON_FILE -> .face"
fi

if [ -e "$FACE_ICON_FILE" ] && [ ! -L "$FACE_ICON_FILE" ]; then
    ensure_owner "$FACE_ICON_FILE"
    chmod 644 "$FACE_ICON_FILE"
fi

if is_root; then
    chown -h "$TARGET_USER:$TARGET_USER" "$FACE_ICON_FILE"
fi

echo
echo "Done. Current state:"
ls -l "$FACE_FILE" "$FACE_ICON_FILE"
