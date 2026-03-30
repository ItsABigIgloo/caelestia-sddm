#!/bin/bash

THEME_NAME="caelestia"
THEME_DIR="/usr/share/sddm/themes/$THEME_NAME"

echo "Creating theme directory..."
if [[ -d "$THEME_DIR" ]]; then
    echo "Existing theme found, replacing it..."
    sudo rm -rf "$THEME_DIR"
fi
sudo mkdir -p "$THEME_DIR"

echo "Copying files to $THEME_DIR..."
sudo cp -r ./* "$THEME_DIR"

sudo rm "$THEME_DIR/install.sh"

echo "Creating template configuration..."
mkdir -p "$HOME/.config/caelestia/templates"
cp -r theme.conf.template "$HOME/.config/caelestia/templates/sddm-theme.conf"

echo "------------------------------------------------"
echo "Installation Complete!"
echo "To enable, edit /etc/sddm.conf or /etc/sddm.conf.d/theme.conf"
echo "Set: Current=$THEME_NAME"
cat <<"EOF"
     ______           __          __  _       
    / ____/___ ____  / /__  _____/ /_(_)___ _ 
   / /   / __ `/ _ \/ / _ \/ ___/ __/ / __ `/ 
  / /___/ /_/ /  __/ /  __(__  ) /_/ / /_/ /  
  \____/\__,_/\___/_/\___/____/\__/_/\__,_/                                             
EOF

echo "------------------------------------------------"
echo "Installation Complete!"
