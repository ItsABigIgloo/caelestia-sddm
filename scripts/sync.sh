#!/usr/bin/env bash
set -euo pipefail

if [ -n "$SUDO_USER" ]; then
    REAL_USER="$SUDO_USER"
else
    echo "ERROR: Cannot determine target user. Try running with sudo." >&2
    exit 1
fi
REAL_HOME=$(getent passwd "$REAL_USER" | cut -d: -f6)
CAEL_STATE="$REAL_HOME/.local/state/caelestia"
THEME_DIR="/usr/share/sddm/themes/caelestia"
USER_COLORS_DIR="$THEME_DIR/assets/userColors"

rm -rf /var/lib/sddm/.cache/sddm-greeter-qt6
mkdir -p "$USER_COLORS_DIR"

# Generate colors via caelestia
if [ "${1:-}" = "--posthook" ]; then
    echo "✓ Running as posthook, skipping color generation"
elif command -v caelestia &>/dev/null; then
    mapfile -t SCHEME < <(sudo -H -u "$REAL_USER" caelestia scheme get --name --mode --variant 2>/dev/null)
    NAME="${SCHEME[0]}"
    MODE="${SCHEME[1]}"
    VARIANT="${SCHEME[2]}"
    if [ -n "$NAME" ] && [ -n "$MODE" ] && [ -n "$VARIANT" ]; then
        sudo -H -u "$REAL_USER" caelestia scheme set --name "$NAME" --mode "$MODE" --variant "$VARIANT" 2>/dev/null
        echo "✓ Generated colors for scheme: $NAME/$MODE/$VARIANT"
    fi
fi

# Per-user avatar
if [ -f "$REAL_HOME/.face" ]; then
    cp -f "$REAL_HOME/.face" "$THEME_DIR/assets/avatar-$REAL_USER.face"
    chmod 644 "$THEME_DIR/assets/avatar-$REAL_USER.face"
    echo "✓ Synced avatar-$REAL_USER.face"
fi

# Per-user wallpaper
if [ -f "$CAEL_STATE/wallpaper/current" ]; then
    rm -f "$THEME_DIR/assets/background-$REAL_USER" 2>/dev/null || true
    cp -f "$CAEL_STATE/wallpaper/current" "$THEME_DIR/assets/background-$REAL_USER"
    chmod 644 "$THEME_DIR/assets/background-$REAL_USER"
    echo "✓ Synced background-$REAL_USER"
fi

# Per-user colors: write theme.conf (for main UI) + generate QML file (for per-user picker)
if [ -f "$CAEL_STATE/theme/sddm-theme.conf" ]; then
    cp -f "$CAEL_STATE/theme/sddm-theme.conf" "$THEME_DIR/theme-$REAL_USER.conf"
    cp -f "$CAEL_STATE/theme/sddm-theme.conf" "$THEME_DIR/theme.conf"

    sys_os="Linux"
    if [ -f /etc/os-release ]; then
        sys_os=$(grep -oP '^PRETTY_NAME="\K[^"]+' /etc/os-release || echo "Linux")
    fi
    sys_host=$(hostname 2>/dev/null || echo "localhost")
    sed -i "s/^os=.*/os=$sys_os/" "$THEME_DIR/theme.conf"
    sed -i "s/^host=.*/host=$sys_host/" "$THEME_DIR/theme.conf"
    sed -i "s/^os=.*/os=$sys_os/" "$THEME_DIR/theme-$REAL_USER.conf"
    sed -i "s/^host=.*/host=$sys_host/" "$THEME_DIR/theme-$REAL_USER.conf"
    chmod 644 "$THEME_DIR/theme.conf" "$THEME_DIR/theme-$REAL_USER.conf"
    echo "✓ Synced theme-$REAL_USER.conf and theme.conf"
fi

# Generate QML userColors file (loaded eagerly, no XHR needed)
if [ -f "$CAEL_STATE/theme/sddm-theme.conf" ]; then
    USER_QML="$USER_COLORS_DIR/$REAL_USER.qml"
    cat > "$USER_QML" << 'QMLHEADER'
import QtQuick
QtObject {
QMLHEADER
    while IFS='=' read -r key value; do
        key=$(echo "$key" | xargs)
        value=$(echo "$value" | xargs)
        [ -z "$key" ] && continue
        case "$key" in
            background|mainCard|subComponents|text|inverseOnSurface)
                echo "    property color $key: \"$value\""
                ;;
        esac
    done < "$CAEL_STATE/theme/sddm-theme.conf" >> "$USER_QML"
    echo "}" >> "$USER_QML"
    chmod 644 "$USER_QML"
    echo "✓ Generated userColors QML for $REAL_USER"
fi
