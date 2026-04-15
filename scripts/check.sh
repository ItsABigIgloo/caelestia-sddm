#!/usr/bin/env bash

THEME_NAME="caelestia"
THEME_DIR="/usr/share/sddm/themes/${THEME_NAME}"
SERVICE_NAME="caelestia-sync.service"

failures=0
warnings=0

ok() {
    printf '[OK] %s\n' "$1"
}

warn() {
    printf '[WARN] %s\n' "$1"
    warnings=$((warnings + 1))
}

fail() {
    printf '[FAIL] %s\n' "$1"
    failures=$((failures + 1))
}

echo "=== Caelestia SDDM Theme Check ==="

echo
echo "--- Theme directory ---"
if [ -d "$THEME_DIR" ]; then
    ok "Theme directory exists: $THEME_DIR"
else
    fail "Theme directory missing: $THEME_DIR"
fi

if [ -x "$THEME_DIR/scripts/sync.sh" ]; then
    ok "sync.sh is executable"
else
    warn "sync.sh is not executable (needed by caelestia-sync service)"
fi

echo
echo "--- Theme config activation ---"
current_matches=()
config_candidates=(
    "/etc/sddm.conf"
    "/etc/sddm.conf.d/*.conf"
    "/usr/lib/sddm/sddm.conf.d/default.conf"
)

for pattern in "${config_candidates[@]}"; do
    for cfg in $pattern; do
        [ -f "$cfg" ] || continue
        if grep -Eq '^Current=caelestia$' "$cfg"; then
            current_matches+=("$cfg")
        fi
    done
done

if [ "${#current_matches[@]}" -gt 0 ]; then
    ok "Current=caelestia found in:"
    for cfg in "${current_matches[@]}"; do
        printf '  - %s\n' "$cfg"
    done
else
    fail "No SDDM config sets Current=caelestia"
fi

echo
echo "--- Fonts ---"
if fc-list | grep -Eiq 'Rubik'; then
    ok "Rubik font is installed (UI text)"
else
    fail "Rubik font missing (UI text will not render)"
fi

font_found=0
if fc-list | grep -iq 'Material Symbols Outlined'; then
    ok "Material Symbols Outlined is installed (minimalist themes)"
    font_found=1
fi
if fc-list | grep -iq 'Material Symbols Rounded'; then
    ok "Material Symbols Rounded is installed (locklike theme)"
    font_found=1
fi
if [ "$font_found" -eq 0 ]; then
    fail "No Material Symbols font found (icons will not render)"
fi

if fc-list | grep -iq 'CaskaydiaCove.*NF'; then
    ok "CaskaydiaCove NF is installed (locklike mono)"
else
    fail "CaskaydiaCove NF missing (locklike mono text will not render)"
fi

echo
echo "--- Dependencies from install.sh ---"
if command -v pacman >/dev/null 2>&1; then
    dep_fail=0
    for pkg in sddm qt6-declarative qt6-5compat qt6-svg qt6-virtualkeyboard ffmpeg; do
        if pacman -Q "$pkg" >/dev/null 2>&1; then
            ok "Package installed: $pkg"
        else
            fail "Package missing: $pkg"
            dep_fail=1
        fi
    done
    if [ "$dep_fail" -eq 0 ]; then
        ok "All install.sh dependencies are present"
    fi
else
    warn "pacman not found, skipping package checks"
fi

echo
echo "--- Optional service check ---"
if [ -f "/etc/systemd/system/${SERVICE_NAME}" ]; then
    ok "Service file exists: /etc/systemd/system/${SERVICE_NAME}"
    if systemctl is-enabled "$SERVICE_NAME" >/dev/null 2>&1; then
        ok "Service is enabled: $SERVICE_NAME"
    else
        warn "Service is not enabled: $SERVICE_NAME"
    fi
else
    warn "Service file missing: /etc/systemd/system/${SERVICE_NAME}"
fi

echo
echo "--- Recent SDDM log issues ---"
if journalctl -u sddm -b --no-pager >/dev/null 2>&1; then
    journalctl -u sddm -b --no-pager | grep -Ei 'error|warning|fail' | tail -20
else
    warn "Could not read journalctl for sddm (try with sudo)"
fi

echo
echo "=== Result ==="
printf 'Failures: %d\n' "$failures"
printf 'Warnings: %d\n' "$warnings"

if [ "$failures" -gt 0 ]; then
    exit 1
fi

exit 0
