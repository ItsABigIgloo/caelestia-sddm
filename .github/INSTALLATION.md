# Installation & Setup

## AUR (Recommended):

Each theme conflicts with each other, so only one can be installed.

```bash
# locklike theme
yay -S caelestia-sddm-locklike-git
```
```bash
# minimalist theme
yay -S caelestia-sddm-minimalist-git
```
```bash
# minimalistV2 theme
yay -S caelestia-sddm-minimalistv2-git
```

> [!TIP]
> To switch theme either remove the currently installed one or accept removal on conflict through AUR.

## Manual:

1. **Clone the repository:**
    ```bash
    git clone https://github.com/ItsABigIgloo/caelestia-sddm.git
    cd caelestia-sddm
    ```

2. **Run the installer:**
    ```bash
    chmod +x scripts/install.sh
    ./scripts/install.sh
    ```

3. **Select a theme:**
    The installer will prompt you to choose from available themes:
    ```
    Available themes:

      1) locklike
      2) minimalist
      3) minimalistV2

    Select theme to install [1-3]:
    ```

> [!NOTE]
> Re-running the installer will automatically clean up the previous installation.
> To switch themes simply re-run the install script again and choose your desired theme.

---

## Syncing:

The theme syncs your current wallpaper, avatar, and colors to the SDDM login screen.

**Manual Sync:**
Manually apply changes immediately without rebooting:
```bash
sudo /usr/share/sddm/themes/caelestia/scripts/sync.sh
```

**Automatic Posthook:**
For fully automated sync on every wallpaper change, use Caelestia's posthook.
- See setup details in **[Posthook](POSTHOOK.md)**.

---

## Testing:

To quickly preview the theme without logging out:
```bash
QML_XHR_ALLOW_FILE_READ=1 QT_QPA_PLATFORM=xcb sddm-greeter-qt6 --test-mode --theme /usr/share/sddm/themes/caelestia
```

> [!NOTE]
> `QML_XHR_ALLOW_FILE_READ=1` is required for quotes to display in test mode. `QT_QPA_PLATFORM=xcb` is required for MultiEffect blur to render correctly.

---

## Configuration:

> [!WARNING]
> Do not edit `/usr/share/sddm/themes/caelestia/theme.conf` directly, since this will be overwritten by Caelestia templating system.

To customize the theme config, modify it only through the Caelestia config:

1. Edit `~/.config/caelestia/templates/sddm-theme.conf`
    ```bash
    # ============= CONFIG FOR LOCKLIKE ==================
    [General]
    # 12 hours or 24 Hours true=12 [true | false]
    ap=false
    # Welcome message background opacity [0.0 to 1.0]
    welcomeBgBlurAmount=0.7
    welcomeColorOpacity=0.7
    # mainCard background opacity and blur [0.0 to 2.0]
    mainCardBlurAmount=0.9
    mainCardColorOpacity=0.9
    mainCardComponentsOpacity=0.9
    # Welcome message background blur [true | false]
    welcomeBgBlur=true
    mainCardBgBlur=true
    ```
2. Apply sync:
   ```bash
   sudo /usr/share/sddm/themes/caelestia/scripts/sync.sh
   ```

> [!TIP]
> **Your config will be overwritten on every update, so make sure to back them up before updating.**
>```bash
>cp ~/.config/caelestia/templates/sddm-theme.conf ~/.config/caelestia/templates/sddm-theme.conf.bak
>```

---

## How it works:

For a deeper explanation of integration with Caelestia and sync flow, see **[Templating](TEMPLATING.md).**

---

## Troubleshooting:

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

## Help:

If you run into any issues not covered above, reach out through:

* **GitHub Issues** — [Report a bug or request a feature](https://github.com/ItsABigIgloo/caelestia-sddm/issues)
* **Discord** — [Join the Caelestia community](https://discord.gg/xPTAT7FFSy)
