<div align="center">

# Caelestia SDDM Theme

[![](https://img.shields.io/github/last-commit/ItsABigIgloo/caelestia-sddm?&style=for-the-badge&color=8ad7eb&logo=git&logoColor=D9E0EE&labelColor=1E202B)](https://github.com/ItsABigIgloo/caelestia-sddm/commit/main)
[![](https://img.shields.io/badge/Caelestia-Shell-8ad7eb?style=for-the-badge&logo=github&logoColor=D9E0EE&labelColor=1E202B)](https://github.com/caelestia-dots/shell)
[![](https://img.shields.io/badge/Caelestia-Repository-86dbd7?style=for-the-badge&logo=github&logoColor=D9E0EE&labelColor=1E202B)](https://github.com/caelestia-dots/caelestia)

</div>

<p align="center">A dynamic, adaptive login interface for <strong>Caelestia Shell</strong>. Built with QML, this theme focuses on wallpaper-driven colors, synchronized visuals, and seamless integration with the Caelestia desktop ecosystem.</p>

<div align="center">
    <h2> Locklike </h2>
    <h3></h3>
</div>

<a href="https://github.com/user-attachments/assets/ef7a6a67-40ba-4274-ac58-50f58a18215c">
<img src="https://github.com/user-attachments/assets/ef7a6a67-40ba-4274-ac58-50f58a18215c" alt="Locklike">
</a>

<div align="center">
    <h2> MinimalistV2 </h2>
    <h3></h3>
</div>

<a href="https://github.com/user-attachments/assets/ef7a6a67-40ba-4274-ac58-50f58a18215c">
<img src="https://github.com/user-attachments/assets/ef7a6a67-40ba-4274-ac58-50f58a18215c" alt="MinimalistV2">
</a>

<div align="center">
    <h2> Minimalist </h2>
    <h3></h3>
</div>

<a href="https://github.com/user-attachments/assets/ef7a6a67-40ba-4274-ac58-50f58a18215c">
<img src="https://github.com/user-attachments/assets/ef7a6a67-40ba-4274-ac58-50f58a18215c" alt="Minimalist">
</a>

## Installation

The provided installer handles all dependencies, system configurations, and permissions automatically.

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/ItsABigIgloo/caelestia-sddm.git
    cd caelestia-sddm
    ```

2.  **Run the installer:**
    ```bash
    chmod +x scripts/install.sh
    ./scripts/install.sh
    ```

3.  **Select a theme:**
    The installer will prompt you to choose from available themes:
    ```
    Available themes:

      1) locklike
      2) minimalist
      3) minimalistV2

    Select theme to install [1-3]:
    ```

> **Note:** Re-running the installer will automatically clean up the previous installation before installing a new theme.
> To Switch theme simply re-run the install script again and choose your desired theme.

## Sync Setup

The theme syncs your current wallpaper, avatar, and colors to the SDDM login screen.

**Manual Sync:**
Manually apply changes immediately without rebooting:
```bash
sudo /usr/share/sddm/themes/caelestia/scripts/sync.sh
```

**Automatic Posthook:**
For fully automated sync on every wallpaper change, use posthook. See **[POSTHOOK.md](POSTHOOK.md)**.

## Configuration

To customize the theme config, modify it only through the Caelestia config:

1. Edit `~/.config/caelestia/templates/sddm-theme.conf`
2. Apply sync:
   ```bash
   sudo /usr/share/sddm/themes/caelestia/scripts/sync.sh
   ```

Do not edit `/usr/share/sddm/themes/caelestia/theme.conf` directly, since this will be overwritten by Caelestia templating system.

> **For a deeper explanation of templating and sync flow, see [TEMPLATING.md](TEMPLATING.md).**

## Testing

Preview the theme without logging out:
```bash
QML_XHR_ALLOW_FILE_READ=1 QT_QPA_PLATFORM=xcb sddm-greeter-qt6 --test-mode --theme /usr/share/sddm/themes/caelestia
```

> **Note:** `QML_XHR_ALLOW_FILE_READ=1` is required for quotes to display in test mode. `QT_QPA_PLATFORM=xcb` is required for MultiEffect blur to render correctly.

## Troubleshooting

**Avatar not updating or showing stale image**

```bash
./scripts/fix-avatar.sh
```

**Caelestia dots, states and config files being owned by root**

```bash
./scripts/fix-permissions.sh
```

**Display or monitors not matching Hyprland config**

Fixes multi-display positioning and orientation:
```bash
./scripts/monitors.sh ~/.config/hypr/Monitors.conf
```

## Requirements

> **Note:** This theme was made for Caelestia Shell, you can still use it on other setups but dynamic colors and wallpapers wont work..

List of requirements:
* **SDDM** duh
* **qt6-declarative**
* **qt6-5compat**
* **qt6-svg**
* **qt6-virtualkeyboard**
* **ffmpeg**
* **Material Symbols Outlined** (required for power/reboot icons)
* **Rubik Font** (default text)
