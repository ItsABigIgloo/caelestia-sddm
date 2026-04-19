#!/usr/bin/env bash
set -euo pipefail

# Prevent running with sudo - the script uses sudo internally for some commands
if [ "$(id -u)" -eq 0 ]; then
    echo "ERROR: Do not run this script with sudo. Run it normally." >&2
    exit 1
fi

THEME_NAME="caelestia"
THEME_DIR="/usr/share/sddm/themes/$THEME_NAME"
TEMPLATE_FILE="$HOME/.config/caelestia/templates/sddm-theme.conf"
TEMPLATE_DIR="$HOME/.config/caelestia/templates"

# --- Sudo check ---
echo "Caelestia SDDM Theme Uninstaller"
echo "This script requires sudo privileges to remove the theme."
echo ""
if ! sudo -v; then
    echo "✗ Sudo authentication failed. Exiting."
    exit 1
fi
echo "✓ Sudo authenticated"
# -----------------

# 1. Remove the SDDM theme directory
echo "Removing SDDM theme from $THEME_DIR..."
if [[ -d "$THEME_DIR" ]]; then
    sudo rm -rf "$THEME_DIR"
    echo "✓ Removed theme directory."
else
    echo "Theme directory not found, skipped."
fi

# 2. Remove SDDM theme configuration
echo "Removing SDDM theme configuration..."
echo "Note: /etc/sddm.conf is left untouched - you may want to manually update Current= setting."
if [[ -f "/etc/sddm.conf.d/caelestia.conf" ]]; then
    sudo rm -f "/etc/sddm.conf.d/caelestia.conf"
    echo "✓ Removed /etc/sddm.conf.d/caelestia.conf."

    # Remove the directory if it's empty
    if [[ -d "/etc/sddm.conf.d" ]] && [[ -z "$(sudo ls -A /etc/sddm.conf.d)" ]]; then
        sudo rmdir "/etc/sddm.conf.d"
        echo "✓ Removed empty /etc/sddm.conf.d directory."
    fi
else
    echo "SDDM config drop-in not found, skipped."
fi

# 3. Remove the template configuration
echo "Removing template file from $TEMPLATE_FILE..."
if [[ -f "$TEMPLATE_FILE" ]]; then
    rm -f "$TEMPLATE_FILE"
    echo "✓ Removed template file."
else
    echo "Template file not found, skipped."
fi

if [[ -d "$TEMPLATE_DIR" ]] && [[ -z "$(ls -A "$TEMPLATE_DIR")" ]]; then
    rmdir "$TEMPLATE_DIR"
    echo "✓ Removed empty template directory."
fi

echo ""
echo "✅ Uninstall complete."
