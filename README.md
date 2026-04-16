<div align="center">

# Caelestia SDDM Theme

![Issues](https://img.shields.io/github/issues/ItsABigIgloo/caelestia-sddm?style=for-the-badge)
[![Caelestia Shell](https://img.shields.io/badge/Caelestia-Shell-111827?style=for-the-badge)](https://github.com/caelestia-dots/shell)
[![Caelestia](https://img.shields.io/badge/Caelestia-Repository-0f172a?style=for-the-badge)](https://github.com/caelestia-dots/caelestia)

</div>

<p align="center">A dynamic, adaptive login interface for <strong>Caelestia Shell</strong>. Built with QML, this theme focuses on wallpaper-driven colors, synchronized visuals, and seamless integration with the Caelestia desktop ecosystem.</p>

<table>
  <tr>
    <td>
      <video src="https://github.com/user-attachments/assets/2fac31f1-0007-4d1d-8966-5ba34ccf7222" width="400" controls autoplay loop muted></video>
    </td>
    <td>
      <video src="https://github.com/user-attachments/assets/6e58f631-56e0-4750-b088-9aeb6d54fa01" width="400" controls autoplay loop muted></video>
    </td>
  </tr>
</table>

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

This theme already includes a systemd service (`caelestia-sync.service`) that triggers during the shutdown/reboot process. It identifies the active user, pulls the latest wallpaper, avatar icons and theme configuration from the Caelestia state folder, and applies them to the login screen for your next boot.

**Manual Sync:**
If you want to apply changes immediately without rebooting, run:
```bash
sudo /usr/share/sddm/themes/caelestia/scripts/sync.sh
```

**Automatic Posthook:**
If you want a fully automated sync without reboot, use posthook. See **[POSTHOOK.md](POSTHOOK.md)**.

## Configuration

To customize the theme config, modify it only through the Caelestia config:

1. Edit `~/.config/caelestia/sddm-theme.conf`
2. Apply sync:
   ```bash
   sudo /usr/share/sddm/themes/caelestia/scripts/sync.sh
   ```

Do not edit `/usr/share/sddm/themes/caelestia/theme.conf` directly, since this will be overwritten by Caelestia templating system.

> **For a deeper explanation of templating and sync flow, see [TEMPLATING.md](TEMPLATING.md).**

## Testing

Preview the theme without logging out:
```bash
QML_XHR_ALLOW_FILE_READ=1 sddm-greeter-qt6 --test-mode --theme /usr/share/sddm/themes/caelestia
```

> **Note:** The `QML_XHR_ALLOW_FILE_READ` environment variable is required for quotes to display in test mode.

## Troubleshooting

**Avatar not updating or showing stale image**

```bash
sudo ./scripts/fix-avatar.sh
```

This keeps `~/.face.icon` synced to `~/.face` and fixes incorrect avatar images.

## Requirements

> **Note:** This theme was made for Caelestia Shell, you can still use it on other setups but dynamic colors and wallpapers wont work..

List of requirements:
* **SDDM** duh
* **qt6-declarative**
* **qt6-5compat**
* **qt6-multimedia**
* **qt6-svg**
* **qt6-virtualkeyboard**
* **ffmpeg**
* **Material Symbols Outlined** (required for power/reboot icons)
* **Rubik Font** (default text)
