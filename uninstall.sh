#!/usr/bin/env bash

set -euo pipefail

THEME_NAME="caelestia"
THEME_DIR="/usr/share/sddm/themes/$THEME_NAME"
TEMPLATE_FILE="$HOME/.config/caelestia/templates/sddm-theme.conf"
TEMPLATE_DIR="$HOME/.config/caelestia/templates"

# Remove the sddm theme
echo "Removing SDDM theme from $THEME_DIR..."
if [[ -d "$THEME_DIR" ]]; then
    sudo rm -rf "$THEME_DIR"
    echo "Removed theme directory."
else
    echo "Theme directory not found, skipped."
fi

# Remove the template configuration
echo "Removing template file from $TEMPLATE_FILE..."
if [[ -f "$TEMPLATE_FILE" ]]; then
    rm -f "$TEMPLATE_FILE"
    echo "Removed template file."
else
    echo "Template file not found, skipped."
fi

if [[ -d "$TEMPLATE_DIR" ]] && [[ -z "$(ls -A "$TEMPLATE_DIR")" ]]; then
    rmdir "$TEMPLATE_DIR"
    echo "Removed empty template directory."
fi

echo "Uninstall complete."
