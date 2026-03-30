#!/usr/bin/env bash

set -euo pipefail

# Configuration
SOURCE_WALLPAPER="$HOME/.local/state/caelestia/wallpaper/current"
THEME_NAME="caelestia"
THEME_DIR="/usr/share/sddm/themes/$THEME_NAME"

# Sync wallpaper
if [[ -f "$SOURCE_WALLPAPER" ]]; then
  if [[ -d "$THEME_DIR/assets" ]]; then
    echo "Syncing wallpaper into installed SDDM theme (requires sudo)..."
    sudo cp "$SOURCE_WALLPAPER" "$THEME_DIR/assets/background.png"
  else
    echo "Installed theme directory not found, skipped wallpaper: $THEME_DIR"
  fi
else
  echo "Wallpaper source not found, skipped: $SOURCE_WALLPAPER"
fi

# Sync theme config colors
SOURCE_THEME_CONF="$HOME/.local/state/caelestia/theme/sddm-theme.conf"

if [[ -f "$SOURCE_THEME_CONF" ]]; then
  echo "Syncing theme.conf into installed SDDM theme (requires sudo)..."
  sudo cp "$SOURCE_THEME_CONF" "$THEME_DIR/theme.conf"
else
  echo "Theme config not found, skipped: $SOURCE_THEME_CONF"
fi

echo "Sync complete."