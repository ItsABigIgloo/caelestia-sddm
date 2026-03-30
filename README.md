# 🌌 Caelestia SDDM Theme

A sleek, obsidian-inspired login interface designed specifically for **CaelestiaOS**. Built with QML, this theme features a minimalist card aesthetic, glassmorphism, and full integration with the Caelestia desktop ecosystem.

![Caelestia SDDM Preview](https://github.com/user-attachments/assets/fbe88fda-3a4c-4570-b3b1-5a5318693165)

## ✨ Features

* **Dynamic Sync:** Automatically matches your SDDM background and accent colors to your current Hyprland theme upon reboot.
* **Multimedia Support:** Supports static images (`.jpg`, `.png`), animated GIFs, and video backgrounds (`.mp4`, `.webm`).
* **Glassmorphism:** A translucent central card with dynamic opacity for seamless background integration.
* **Smart Fallbacks:** Automatically uses system user avatars (~/.face.icon) or falls back to the Caelestia logo.

## 🛠️ Installation

The provided installer handles all dependencies, system configurations, and permissions automatically.

1.  **Clone the repository:**
    ```bash
    git clone [https://github.com/your-username/caelestia-sddm.git](https://github.com/your-username/caelestia-sddm.git)
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

## 🔄 How the Sync Works

This theme already includes a systemd service (`caelestia-sync.service`) that triggers during the shutdown/reboot process. It identifies the active user, pulls the latest wallpaper and theme configuration from the Caelestia state folder, and applies them to the login screen for your next boot.

**Manual Sync:**
If you want to apply changes immediately without rebooting, run:
```bash
sudo /usr/share/sddm/themes/caelestia/scripts/sync.sh
```

**Automatic Posthook:**
If you want FULL automatic without reboot use posthook, see [POSTHOOK.md](POSTHOOK.md).
> **For a deeper explanation of templating and sync flow, see [TEMPLATING.md](TEMPLATING.md).**

## ⚙️ Configuration

To Customize the theme config modify it ONLY through the Caelestia config:

1. Edit `~/.config/caelestia/sddm-theme.conf`
2. Select a wallpaper (to tigger color generation)
2. Apply sync:
   ```bash
   sudo /usr/share/sddm/themes/caelestia/scripts/sync.sh
   ```

Do not edit `/usr/share/sddm/themes/caelestia/theme.conf` directly, since this will be overwritten by Caelestia templating system.


## 🧪 TESTING- Preview the theme without logging out

`sddm-greeter --test-mode --theme /usr/share/sddm/themes/caelestia`

## 🤝 Requirements

Caelestia shell meets all the basic requirements, except for SDDM(which is a requirement or an SDDM theme).

for everyone not on Caelestia Shell:
* **SDDM** duh
* **qt6-multimedia**
* **ffmpeg**
* **qt6-svg**
* **qt6-virtualkeyboard**
* **Material Symbols Outlined** (required for power/reboot icons)
* **Rubik Font** (default texts)
