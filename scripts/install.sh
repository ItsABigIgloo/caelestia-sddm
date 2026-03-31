#!/usr/bin/env bash
set -e

# Dynamically find the project root regardless of where this script is called from
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

THEME_NAME="caelestia"

# --- Dependency Check ---
DEPENDENCIES=(
    "sddm"
    "qt6-svg"
    "qt6-virtualkeyboard"
    "ffmpeg"
)

echo "🔍 Checking dependencies..."
MISSING_PKGS=()

for pkg in "${DEPENDENCIES[@]}"; do
    if ! pacman -Qs "$pkg" > /dev/null; then
        MISSING_PKGS+=("$pkg")
    fi
done

if [ ${#MISSING_PKGS[@]} -gt 0 ]; then
    echo "📦 Missing packages found: ${MISSING_PKGS[*]}"
    echo "Installing missing dependencies..."
    sudo pacman -S --noconfirm "${MISSING_PKGS[@]}"
else
    echo "✓ All dependencies met."
fi
# ------------------------

INSTALL_DIR="/usr/share/sddm/themes/$THEME_NAME"

echo "🌌 Installing Caelestia SDDM Theme..."

# 1. Create theme directory and copy project files
sudo mkdir -p "$INSTALL_DIR"
sudo cp -r "$PROJECT_ROOT"/* "$INSTALL_DIR/"
echo "✓ Copied theme to $INSTALL_DIR"

# 2. Create template configuration in user's home directory
echo "Creating color template configuration..."
mkdir -p "$HOME/.config/caelestia/templates"
cp "$INSTALL_DIR/theme.conf.template" "$HOME/.config/caelestia/templates/sddm-theme.conf"
echo "✓ Template created at ~/.config/caelestia/templates/sddm-theme.conf"

# 3. Install the Systemd Service from the /components folder
if [ -f "$PROJECT_ROOT/components/caelestia-sync.service" ]; then
    sudo cp "$PROJECT_ROOT/components/caelestia-sync.service" /etc/systemd/system/
    sudo systemctl daemon-reload
    sudo systemctl enable caelestia-sync.service
    echo "✓ Service installed and enabled"
else
    echo "✗ Error: caelestia-sync.service not found in /components/"
    exit 1
fi

# 4. Fix permissions so sync.sh can update assets without sudo later
sudo chown -R root:root "$INSTALL_DIR"
sudo chmod -R 755 "$INSTALL_DIR"
sudo chmod -R 777 "$INSTALL_DIR/assets"
sudo chmod 666 "$INSTALL_DIR/theme.conf"
sudo chmod +x "$INSTALL_DIR/scripts/sync.sh"

#5. Set the Current theme to Caelestia in SDDM configuration
# Force Current theme in all possible config locations
for config in /usr/lib/sddm/sddm.conf.d/default.conf; do
    if [ -f "$config" ]; then
        sudo sed -i 's/^Current=.*/Current=caelestia/' "$config"
    fi
done

# Handle /etc/sddm.conf - create or update
if [ -f /etc/sddm.conf ]; then
    # File exists, update the Current setting
    sudo sed -i 's/^Current=.*/Current=caelestia/' /etc/sddm.conf
    echo "✓ Updated /etc/sddm.conf"
else
    # File doesn't exist, create it
    echo -e "[Theme]\nCurrent=caelestia" | sudo tee /etc/sddm.conf > /dev/null
    echo "✓ Created /etc/sddm.conf"
fi

# Ensure the drop-in exists too
sudo mkdir -p /etc/sddm.conf.d
echo -e "[Theme]\nCurrent=caelestia" | sudo tee /etc/sddm.conf.d/caelestia.conf > /dev/null
echo "✓ Created /etc/sddm.conf.d/caelestia.conf"


echo "✅ Installation Complete! Use './scripts/check.sh' to verify."
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
