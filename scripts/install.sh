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
    "qt6-multimedia" 
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

# 2. Install the Systemd Service from the /components folder
if [ -f "$PROJECT_ROOT/components/caelestia-sync.service" ]; then
    sudo cp "$PROJECT_ROOT/components/caelestia-sync.service" /etc/systemd/system/
    sudo systemctl daemon-reload
    sudo systemctl enable caelestia-sync.service
    echo "✓ Service installed and enabled"
else
    echo "✗ Error: caelestia-sync.service not found in /components/"
    exit 1
fi

# 3. Fix permissions so sync.sh can update assets without sudo later
sudo chown -R root:root "$INSTALL_DIR"
sudo chmod -R 755 "$INSTALL_DIR"
sudo chmod -R 777 "$INSTALL_DIR/assets"
sudo chmod 666 "$INSTALL_DIR/theme.conf"
sudo chmod +x "$INSTALL_DIR/scripts/sync.sh"

# Force Current theme in all possible config locations
for config in /etc/sddm.conf /usr/lib/sddm/sddm.conf.d/default.conf; do
    if [ -f "$config" ]; then
        sudo sed -i 's/^Current=.*/Current=caelestia/' "$config"
    fi
done

# Ensure the drop-in exists too
echo -e "[Theme]\nCurrent=caelestia" | sudo tee /etc/sddm.conf.d/caelestia.conf > /dev/null

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
