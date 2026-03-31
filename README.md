<div align="center">

# Caelestia SDDM Theme

![Issues](https://img.shields.io/github/issues/ItsABigIgloo/caelestia-sddm?style=for-the-badge)
[![Caelestia Shell](https://img.shields.io/badge/Caelestia-Shell-111827?style=for-the-badge)](https://github.com/caelestia-dots/shell)
[![Caelestia](https://img.shields.io/badge/Caelestia-Repository-0f172a?style=for-the-badge)](https://github.com/caelestia-dots/caelestia)

</div>

<p align="center">A dynamic, adaptive login interface for <strong>CaelestiaOS</strong>. Built with QML, this theme focuses on wallpaper-driven colors, synchronized visuals, and seamless integration with the Caelestia desktop ecosystem.</p>

![Caelestia SDDM Preview](https://github.com/user-attachments/assets/5e6cf46d-afce-4b84-91bd-9c88028006d5)

## Features

* **Dynamic Sync:** Automatically matches your SDDM background and accent colors to your current Hyprland theme upon reboot.
* **Multimedia Support:** Supports static images (`.jpg`, `.png`), animated GIFs, and video backgrounds (`.mp4`, `.webm`).
* **Glassmorphism:** A translucent central card with dynamic opacity for seamless background integration.
* **Smart Avatar Fallbacks:** Uses `userModel.icon`, then `~/.face.icon`, then `~/.face`, then falls back to the Caelestia logo.
* **Qt6 Theme Runtime:** Configured with `QtVersion=6` for modern SDDM greeter compatibility.

## Installation

The provided installer handles all dependencies, system configurations, and permissions automatically.

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/ItsABigIgloo/caelestia-sddm.git
    cd caelestia-sddm
    ```

2.  **Run the universal installer:**
    ```bash
    chmod +x scripts/install.sh
    ./scripts/install.sh
    ```

3.  **Verify the setup:**
    ```bash
    chmod +x scripts/check.sh
    ./scripts/check.sh
    ```

## How the Sync Works

This theme already includes a systemd service (`caelestia-sync.service`) that triggers during the shutdown/reboot process. It identifies the active user, pulls the latest wallpaper, avatar icons and theme configuration from the Caelestia state folder, and applies them to the login screen for your next boot.

**Manual Sync:**
If you want to apply changes immediately without rebooting, run:
```bash
sudo /usr/share/sddm/themes/caelestia/scripts/sync.sh
```

**Automatic Posthook:**
If you want fully automatic sync without reboot, use posthook. See [POSTHOOK.md](POSTHOOK.md).
> **For a deeper explanation of templating and sync flow, see [TEMPLATING.md](TEMPLATING.md).**

## Configuration

To customize the theme config, modify it only through the Caelestia config:

1. Edit `~/.config/caelestia/sddm-theme.conf`
2. Select a wallpaper (to trigger color generation)
2. Apply sync:
   ```bash
   sudo /usr/share/sddm/themes/caelestia/scripts/sync.sh
   ```

Do not edit `/usr/share/sddm/themes/caelestia/theme.conf` directly, since this will be overwritten by Caelestia templating system.


## TESTING- Preview the theme without logging out

```bash
sddm-greeter-qt6 --test-mode --theme /usr/share/sddm/themes/caelestia
```

## Troubleshooting

**Avatar not updating or showing stale image**

```bash
sudo ./scripts/fix-avatar.sh
```

This keeps `~/.face.icon` synced to `~/.face` and fixes incorrect avatar images.

## Requirements

> **Note:** This theme requires **Qt 6.2+** for background blur effects (`MultiEffect`). Most modern distributions ship with Qt 6.2+, but verify your version with `pacman -Q qt6-declarative`.

Caelestia Shell meets all the basic requirements, except for SDDM (which is required for an SDDM theme).

For everyone not on Caelestia Shell:
* **SDDM** duh
* **qt6-declarative**
* **qt6-5compat**
* **qt6-multimedia**
* **qt6-svg**
* **qt6-virtualkeyboard**
* **ffmpeg**
* **Material Symbols Outlined** (required for power/reboot icons)
* **Rubik Font** (default text)
