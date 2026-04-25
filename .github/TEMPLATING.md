# How Caelestia Templating Works

This file explains how Caelestia generates colors for the SDDM theme.

## 1) Template source

Caelestia reads "User" templates from:

- `~/.config/caelestia/templates/`

For this theme, the template file is:

- `~/.config/caelestia/templates/sddm-theme.conf`

## 2) Template format

The template uses placeholders (Material You style), for example:

```ini
mPrimary=#{{ primary.hex }}
mOnPrimary=#{{ onPrimary.hex }}
```

## 3) Generated output

Caelestia read the template and renders those placeholders into real color values and writes them to:

- `~/.local/state/caelestia/theme/sddm-theme.conf`

Example generated values:

```ini
mPrimary=#99ccf9
mOnPrimary=#003351
```

## 4) What the scripts do

- `scripts/install.sh` installs the template to `~/.config/caelestia/templates/sddm-theme.conf`.
- `scripts/sync.sh` copies generated values from `~/.local/state/caelestia/theme/sddm-theme.conf` to `/usr/share/sddm/themes/caelestia/theme.conf`.

## 5) Which file should you edit?

Edit this file for your custom values:

- `~/.config/caelestia/templates/sddm-theme.conf`

Do not edit `/usr/share/sddm/themes/caelestia/theme.conf` directly, because sync will overwrite it.
