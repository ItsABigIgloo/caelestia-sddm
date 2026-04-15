#!/usr/bin/env bash
set -e

# Dynamically find the project root regardless of where this script is called from
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
THEMES_DIR="$PROJECT_ROOT/themes"

THEME_NAME="caelestia"
INSTALL_DIR="/usr/share/sddm/themes/$THEME_NAME"

# --- Sudo check ---
echo "Caelestia SDDM Theme Installer"
echo "This script requires sudo privileges to install the theme."
echo ""
if ! sudo -v; then
    echo "✗ Sudo authentication failed. Exiting."
    exit 1
fi
echo "✓ Sudo authenticated"
# -----------------

# --- Check for existing installation ---
if [[ -d "$INSTALL_DIR" ]]; then
    echo ""
    echo "============================================================"
    echo "                    CLEAN UP / UPDATE"
    echo "============================================================"
    echo "Previous installation exists, cleaning and updating..."
    chmod +x "$SCRIPT_DIR/uninstall.sh"
    "$SCRIPT_DIR/uninstall.sh"
fi
# ------------------------

# --- Dependency Check ---
echo ""
echo "============================================================"
echo "                       INSTALL THEME"
echo "============================================================"

DEPENDENCIES=(
    "sddm"
    "qt6-declarative"
    "qt6-5compat"
    "qt6-svg"
    "qt6-virtualkeyboard"
    "ffmpeg"
)

echo "Checking dependencies..."
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

# --- Theme Selection ---
echo ""
echo "Available themes:"
echo ""

# Get list of available themes
THEMES=()
THEME_NUM=1
for theme_path in "$THEMES_DIR"/*/; do
    if [ -d "$theme_path" ]; then
        theme_name=$(basename "$theme_path")
        THEMES+=("$theme_name")
        echo "  $THEME_NUM) $theme_name"
        ((THEME_NUM++))
    fi
done

if [ ${#THEMES[@]} -eq 0 ]; then
    echo "✗ Error: No themes found in $THEMES_DIR"
    exit 1
fi

echo ""
read -p "Select theme to install [1-${#THEMES[@]}]: " selection

# Validate selection
if ! [[ "$selection" =~ ^[0-9]+$ ]] || [ "$selection" -lt 1 ] || [ "$selection" -gt ${#THEMES[@]} ]; then
    echo "✗ Invalid selection"
    exit 1
fi

SELECTED_THEME="${THEMES[$((selection-1))]}"
THEME_SOURCE="$THEMES_DIR/$SELECTED_THEME"

echo ""
echo "Installing Caelestia SDDM Theme ($SELECTED_THEME)..."

# 1. Create theme directory and copy selected theme files
sudo mkdir -p "$INSTALL_DIR"

# Copy all files from selected theme
sudo cp -r "$THEME_SOURCE"/* "$INSTALL_DIR/"

# Copy universal sync script
sudo mkdir -p "$INSTALL_DIR/scripts"
sudo cp "$PROJECT_ROOT/scripts/sync.sh" "$INSTALL_DIR/scripts/"

echo "✓ Copied theme '$SELECTED_THEME' to $INSTALL_DIR"

# 2. Create template configuration in user's home directory
echo "Creating color template configuration..."
mkdir -p "$HOME/.config/caelestia/templates"
cp "$THEME_SOURCE/theme.conf.template" "$HOME/.config/caelestia/templates/sddm-theme.conf"
echo "✓ Template created at ~/.config/caelestia/templates/sddm-theme.conf"

# 3. Install the Systemd Service
if [ -f "$PROJECT_ROOT/scripts/caelestia-sync.service" ]; then
    sudo cp "$PROJECT_ROOT/scripts/caelestia-sync.service" /etc/systemd/system/
    sudo systemctl daemon-reload
    sudo systemctl enable caelestia-sync.service
    echo "✓ Service installed and enabled"
else
    echo "✗ Error: caelestia-sync.service not found in /scripts/"
    exit 1
fi

# 4. Fix permissions so sync.sh have proper root access
sudo chown -R root:root "$INSTALL_DIR"
sudo chmod -R 755 "$INSTALL_DIR"
sudo chmod -R 777 "$INSTALL_DIR/assets"
sudo chmod 644 "$INSTALL_DIR/theme.conf"
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


# 6. Run sync script
echo "Running initial sync..."
sudo "$INSTALL_DIR/scripts/sync.sh"
echo "✓ Initial sync complete"

echo ""
echo "✅ Installation Complete!"
echo "Set: Current=$THEME_NAME"
cat <<"EOF"
     ______           __          __  _
    / ____/___ ____  / /__  _____/ /_(_)___ _
   / /   / __ `/ _ \/ / _ \/ ___/ __/ / __ `/
  / /___/ /_/ /  __/ /  __(__  ) /_/ / /_/ /
  \____/\__,_/\___/_/\___/____/\__/_/\__,_/
EOF

echo "------------------------------------------------"

# Ask to run post-install checks
read -p "Run post-install checks? [Y/n]: " run_check
if [[ -z "$run_check" ]] || [[ "$run_check" =~ ^[Yy]$ ]]; then
    echo ""
    echo "============================================================"
    echo "                    POST-INSTALL CHECKS"
    echo "============================================================"
    chmod +x "$SCRIPT_DIR/check.sh"
    "$SCRIPT_DIR/check.sh"
fi
