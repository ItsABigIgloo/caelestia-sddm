#!/usr/bin/env bash
set -euo pipefail

THEME_DIR="/usr/share/sddm/themes/caelestia"
USER_COLORS_DIR="$THEME_DIR/assets/userColors"

usage() {
    cat <<EOF
Usage: sync.sh [OPTIONS]

Options:
  --user USERNAME    Sync specific user (with D-Bus if available)
  --all              Sync all UID>=1000 users (with D-Bus if available)
  --boot             Sync all users, copy assets only (no D-Bus, no systemd)
  --install          Like --boot, then install per-user path units + sudoers
  --cleanup          Remove all installed systemd units and sudoers
  --help             Show this help

Without options: sync current user (SUDO_USER or whoami), with D-Bus.
EOF
    exit 0
}

_SYNC_ALL=false; _BOOT=false; _INSTALL=false; _CLEANUP=false; _TARGET_USER=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        --help) usage ;;
        --user) shift; _TARGET_USER="$1" ;;
        --all) _SYNC_ALL=true ;;
        --boot) _BOOT=true ;;
        --install) _INSTALL=true ;;
        --cleanup) _CLEANUP=true ;;
        *) echo "Unknown: $1"; usage ;;
    esac; shift
done

get_all_users() {
    awk -F: '$3 >= 1000 && $3 < 65534 && $1 != "nobody" {print $1}' /etc/passwd
}

sync_user() {
    local user="$1" no_dbus="${2:-false}"
    local real_home
    real_home=$(getent passwd "$user" | cut -d: -f6) || { echo "  ✗ User '$user' not found"; return; }
    local cael_state="$real_home/.local/state/caelestia"

    rm -rf /var/lib/sddm/.cache/sddm-greeter-qt6
    mkdir -p "$USER_COLORS_DIR"

    if ! $no_dbus && command -v caelestia &>/dev/null; then
        mapfile -t SCHEME < <(sudo -H -u "$user" caelestia scheme get --name --mode --variant 2>/dev/null || true)
        local n="${SCHEME[0]-}" m="${SCHEME[1]-}" v="${SCHEME[2]-}"
        if [ -n "$n" ] && [ -n "$m" ] && [ -n "$v" ]; then
            sudo -H -u "$user" caelestia scheme set --name "$n" --mode "$m" --variant "$v" 2>/dev/null || true
            echo "  ✓ [$user] Colors: $n/$m/$v"
        fi
    fi

    if [ -f "$real_home/.face" ]; then
        cp -f "$real_home/.face" "$THEME_DIR/assets/avatar-$user.face"
        chmod 644 "$THEME_DIR/assets/avatar-$user.face"
        echo "  ✓ [$user] avatar"
    fi

    if [ -f "$cael_state/wallpaper/current" ]; then
        rm -f "$THEME_DIR/assets/background-$user" 2>/dev/null || true
        cp -f "$cael_state/wallpaper/current" "$THEME_DIR/assets/background-$user"
        chmod 644 "$THEME_DIR/assets/background-$user"
        echo "  ✓ [$user] wallpaper"
    fi

    if [ -f "$cael_state/theme/sddm-theme.conf" ]; then
        cp -f "$cael_state/theme/sddm-theme.conf" "$THEME_DIR/theme-$user.conf"
        local os="Linux"; [ -f /etc/os-release ] && os=$(grep -oP '^PRETTY_NAME="\K[^"]+' /etc/os-release || echo "Linux")
        local hst; hst=$(hostname 2>/dev/null || echo "localhost")
        sed -i "s/^os=.*/os=$os/; s/^host=.*/host=$hst/" "$THEME_DIR/theme-$user.conf"
        cp -f "$THEME_DIR/theme-$user.conf" "$THEME_DIR/theme.conf"
        chmod 644 "$THEME_DIR/theme.conf" "$THEME_DIR/theme-$user.conf"
        echo "  ✓ [$user] theme.conf"

        local qml="$USER_COLORS_DIR/$user.qml"
        {
            echo 'import QtQuick'
            echo 'QtObject {'
            while IFS='=' read -r k v; do
                k=$(echo "$k" | xargs); v=$(echo "$v" | xargs)
                [ -z "$k" ] && continue
                case "$k" in
                    background|mainCard|subComponents|text|inverseOnSurface|primary|secondary|textDark|onPrimary|onSuccess|outline)
                        echo "    property color $k: \"$v\"" ;;
                esac
            done < "$cael_state/theme/sddm-theme.conf"
            echo '}'
        } > "$qml"
        chmod 644 "$qml"
        echo "  ✓ [$user] userColors QML"
    fi
}

install_user_units() {
    local users=("$@")
    for user in "${users[@]}"; do
        local home; home=$(getent passwd "$user" | cut -d: -f6)
        local dir="$home/.config/systemd/user"
        mkdir -p "$dir"

        cat > "$dir/caelestia-sync.path" <<PATHU
[Unit]
Description=Caelestia auto sync for $user

[Path]
PathChanged=%h/.local/state/caelestia/wallpaper/current
PathChanged=%h/.local/state/caelestia/theme/sddm-theme.conf

[Install]
WantedBy=default.target
PATHU

        cat > "$dir/caelestia-sync.service" <<SVCU
[Unit]
Description=Caelestia SDDM sync for $user

[Service]
Type=oneshot
ExecStart=/usr/bin/sudo /usr/share/sddm/themes/caelestia/scripts/sync.sh --user $user
SVCU

        chown -R "$user:$user" "$home/.config/systemd"
        chmod 644 "$dir/caelestia-sync.path" "$dir/caelestia-sync.service"
        loginctl enable-linger "$user" 2>/dev/null || true
        sudo -u "$user" systemctl --user daemon-reload 2>/dev/null || true
        sudo -u "$user" systemctl --user enable caelestia-sync.path 2>/dev/null || true
        echo "  ✓ [$user] path unit enabled"
    done
}

install_sudoers() {
    if [ ! -f /etc/sudoers.d/caelestia-sddm-sync ]; then
        echo "ALL ALL=(root) NOPASSWD: $THEME_DIR/scripts/sync.sh" > /etc/sudoers.d/caelestia-sddm-sync
        chmod 440 /etc/sudoers.d/caelestia-sddm-sync
        echo "✓ sudoers drop-in created"
    fi
}

cleanup() {
    echo "=== Cleanup ==="
    for user in $(get_all_users); do
        local home; home=$(getent passwd "$user" | cut -d: -f6)
        local dir="$home/.config/systemd/user"
        sudo -u "$user" systemctl --user disable caelestia-sync.path 2>/dev/null || true
        rm -f "$dir/caelestia-sync.path" "$dir/caelestia-sync.service"
        echo "  ✓ [$user] units removed"
    done
    rm -f /etc/sudoers.d/caelestia-sddm-sync
    echo "✓ sudoers removed"
    rm -rf /var/lib/sddm/.cache/sddm-greeter-qt6
    echo "Cleanup done"
}

[ "$(id -u)" -eq 0 ] || { echo "Run as root." >&2; exit 1; }

if [ "$_CLEANUP" = true ]; then cleanup; exit 0; fi
if [ "$_INSTALL" = true ]; then _BOOT=true; fi

if [ "$_SYNC_ALL" = true ] || [ "$_BOOT" = true ]; then
    mapfile -t users < <(get_all_users)
    [ ${#users[@]} -eq 0 ] && { echo "No users."; exit 0; }
    echo "Syncing ${#users[@]} user(s)..."
    for u in "${users[@]}"; do sync_user "$u" "$_BOOT"; done
    if [ "$_INSTALL" = true ]; then install_sudoers; install_user_units "${users[@]}"; fi
    exit 0
fi

if [ -n "$_TARGET_USER" ]; then echo "=== $_TARGET_USER ==="; sync_user "$_TARGET_USER"; exit 0; fi
sync_user "${SUDO_USER:-$(whoami)}"