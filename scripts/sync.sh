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
  --posthook         Alias for --boot (used by Caelestia CLI postHook)
  --install          Like --boot, then create sudoers drop-in
  --cleanup          Remove sudoers drop-in
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
        --boot|--posthook) _BOOT=true ;;
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

    # --- Merge: theme.conf (defaults) + user.conf (overrides) + colors ---
    local merged="$THEME_DIR/theme.conf"
    local user_conf="$THEME_DIR/user.conf"

    if [ -f "$user_conf" ]; then
        python3 -c "
with open('$merged') as f: base = f.readlines()
with open('$user_conf') as f: overrides = f.readlines()
override_map = {}
for line in overrides:
    s = line.strip()
    if '=' in s and not s.startswith('#'):
        k, v = s.split('=', 1)
        override_map[k.strip()] = v.strip()
written = set()
with open('$merged', 'w') as f:
    for line in base:
        s = line.strip()
        key = s.split('=')[0].strip() if '=' in s else ''
        if key in override_map:
            f.write(f'{key}={override_map[key]}\n')
            written.add(key)
        else:
            f.write(line)
    for k, v in override_map.items():
        if k not in written:
            f.write(f'{k}={v}\n')
" 2>/dev/null || true
    fi

    if [ -f "$cael_state/theme/sddm-theme.conf" ]; then
        python3 -c "
import json
with open('$cael_state/theme/sddm-theme.conf') as f:
    lines = f.readlines()
m = {}
for line in lines:
    line = line.strip()
    if '=' in line:
        k, v = line.split('=', 1)
        k = k.strip(); v = v.strip().lstrip('#')
        if k in ('background','mainCard','subComponents','text','textDark',
                 'primary','onPrimary','secondary','onSuccess','inverseOnSurface','outline'):
            m[k] = v
cf = '$merged'
with open(cf) as f: existing = f.readlines()
written = set()
with open(cf, 'w') as f:
    for line in existing:
        s = line.strip()
        key = s.split('=')[0].strip() if '=' in s else ''
        if key in m:
            f.write(f'{key}=#{m[key]}\n')
            written.add(key)
        else:
            f.write(line)
    for k, v in m.items():
        if v and k not in written:
            f.write(f'{k}=#{v}\n')
" 2>/dev/null || true
    elif [ -f "$cael_state/scheme.json" ]; then
        python3 -c "
import json
with open('$cael_state/scheme.json') as f: s = json.load(f)
c = s.get('colours', {})
m = {
    'background': c.get('background'),
    'mainCard': c.get('surfaceContainer'),
    'subComponents': c.get('surfaceContainerHigh'),
    'text': c.get('onSurface'),
    'textDark': c.get('onSurfaceVariant'),
    'primary': c.get('primary'),
    'onPrimary': c.get('onPrimary'),
    'secondary': c.get('secondary'),
    'onSuccess': c.get('onSuccess'),
    'inverseOnSurface': c.get('inverseOnSurface'),
    'outline': c.get('outline'),
}
cf = '$merged'
with open(cf) as f: lines = f.readlines()
written = set()
with open(cf, 'w') as f:
    for line in lines:
        s = line.strip()
        key = s.split('=')[0].strip() if '=' in s else ''
        if key in m and m[key]:
            f.write(f'{key}=#{m[key]}\n')
            written.add(key)
        else:
            f.write(line)
    for k, v in m.items():
        if v and k not in written:
            f.write(f'{k}=#{v}\n')
" 2>/dev/null || true
    fi

    local os="Linux"; [ -f /etc/os-release ] && os=$(grep -oP '^PRETTY_NAME="\K[^"]+' /etc/os-release || echo "Linux")
    local hst; hst=$(hostname 2>/dev/null || echo "localhost")
    sed -i "s/^os=.*/os=$os/; s/^host=.*/host=$hst/" "$merged" 2>/dev/null || true
    chmod 644 "$merged"
    echo "  ✓ [$user] theme.conf"

    # Generate theme-$user.conf with colors only (for userColors.js)
    local user_colors="$THEME_DIR/theme-$user.conf"
    echo '[General]' > "$user_colors"
    if [ -f "$cael_state/theme/sddm-theme.conf" ]; then
        sed -n '/^background=\|^mainCard=\|^subComponents=\|^text=\|^textDark=\|^primary=\|^onPrimary=\|^secondary=\|^onSuccess=\|^inverseOnSurface=\|^outline=/p' "$merged" >> "$user_colors" 2>/dev/null || true
    elif [ -f "$cael_state/scheme.json" ]; then
        python3 -c "
import json
with open('$cael_state/scheme.json') as f: s = json.load(f)
c = s.get('colours', {})
keys = ['background','mainCard','subComponents','text','textDark','primary','onPrimary','secondary','onSuccess','inverseOnSurface','outline']
with open('$user_colors', 'a') as f:
    f.write('host=$hst\nos=$os\n')
    for k in keys:
        v = c.get(k)
        if v:
            f.write(f'{k}=#{v}\n')
" 2>/dev/null || true
    fi
    chmod 644 "$user_colors"
}

generate_colors_js() {
    local users=("$@")
    local js="$USER_COLORS_DIR/userColors.js"
    mkdir -p "$USER_COLORS_DIR"
    {
        echo '// Auto-generated by sync.sh — do not edit manually'
        echo 'var colors = {'
        local first=true
        for user in "${users[@]}"; do
            local conf="$THEME_DIR/theme-$user.conf"
            [ ! -f "$conf" ] && continue
            $first || echo ','
            first=false
            echo -n "  \"$user\": {"
            local inner_first=true
            while IFS='=' read -r k v; do
                k=$(echo "$k" | xargs); v=$(echo "$v" | xargs)
                [ -z "$k" ] && continue
                case "$k" in
                    background|mainCard|subComponents|text|inverseOnSurface|primary|secondary|textDark|onPrimary|onSuccess|outline)
                        $inner_first || echo -n ', '
                        inner_first=false
                        echo -n "\"$k\": \"$v\""
                        ;;
                esac
            done < "$conf"
            echo -n '}'
        done
        echo ''
        echo '};'
    } > "$js"
    chmod 644 "$js"
    echo "✓ Generated userColors.js (${#users[@]} users)"
}

install_posthook() {
    local users=("$@")
    local hook="sudo $THEME_DIR/scripts/sync.sh --posthook"
    for user in "${users[@]}"; do
        local home; home=$(getent passwd "$user" | cut -d: -f6)
        local cli="$home/.config/caelestia/cli.json"
        mkdir -p "$home/.config/caelestia"

        if [ -f "$cli" ] && grep -q '"postHook"' "$cli" 2>/dev/null; then
            echo "  ✓ [$user] postHook already set"
            continue
        fi

        if [ -f "$cli" ]; then
            python3 -c "
import json
with open('$cli') as f: data = json.load(f)
data.setdefault('wallpaper', {})['postHook'] = '$hook'
data.setdefault('theme', {})['postHook'] = '$hook'
with open('$cli', 'w') as f: json.dump(data, f, indent=4)
"
        else
            cat > "$cli" <<CLI
{
    "wallpaper": {
        "postHook": "$hook"
    },
    "theme": {
        "postHook": "$hook"
    }
}
CLI
        fi
        chown "$user:$user" "$cli"
        echo "  ✓ [$user] postHook added"
    done
}

cleanup_posthook() {
    for user in $(get_all_users); do
        local home; home=$(getent passwd "$user" | cut -d: -f6)
        local cli="$home/.config/caelestia/cli.json"
        [ ! -f "$cli" ] && continue
        python3 -c "
import json
with open('$cli') as f: data = json.load(f)
changed = False
for key in ['wallpaper', 'theme']:
    if key in data and 'postHook' in data[key]:
        del data[key]['postHook']
        changed = True
        if not data[key]:
            del data[key]
if changed:
    with open('$cli', 'w') as f: json.dump(data, f, indent=4)
"
        echo "  ✓ [$user] postHook removed"
    done
}

install_sudoers() {
    if [ ! -f /etc/sudoers.d/caelestia-sddm-sync ]; then
        mkdir -p /etc/sudoers.d
        echo "ALL ALL=(root) NOPASSWD: $THEME_DIR/scripts/sync.sh" > /etc/sudoers.d/caelestia-sddm-sync
        chmod 440 /etc/sudoers.d/caelestia-sddm-sync
        echo "✓ sudoers drop-in created"
    fi
}

cleanup() {
    echo "=== Cleanup ==="
    cleanup_posthook
    rm -f /etc/sudoers.d/caelestia-sddm-sync
    echo "✓ sudoers removed"
    rm -rf /var/lib/sddm/.cache/sddm-greeter-qt6
    echo "Cleanup done"
}

[ "$(id -u)" -eq 0 ] || { echo "Run as root." >&2; exit 1; }

if [ "$_CLEANUP" = true ]; then cleanup; exit 0; fi
if [ "$_INSTALL" = true ]; then _BOOT=true; fi

if [ -n "$_TARGET_USER" ]; then
    if [ "$_SYNC_ALL" = true ] || [ "$_BOOT" = true ]; then
        echo "ERROR: --user is incompatible with --all/--boot/--install" >&2
        exit 1
    fi
    sync_user "$_TARGET_USER" true
    generate_colors_js "$_TARGET_USER"
    exit 0
fi

if [ "$_SYNC_ALL" = true ] || [ "$_BOOT" = true ]; then
    mapfile -t users < <(get_all_users)
    [ ${#users[@]} -eq 0 ] && { echo "No users."; exit 0; }
    echo "Syncing ${#users[@]} user(s)..."
    for u in "${users[@]}"; do sync_user "$u" true; done
    generate_colors_js "${users[@]}"
    if [ "$_INSTALL" = true ]; then install_sudoers; install_posthook "${users[@]}"; fi
    exit 0
fi

CURRENT_USER="${SUDO_USER:-$(whoami)}"
sync_user "$CURRENT_USER"
generate_colors_js "$CURRENT_USER"