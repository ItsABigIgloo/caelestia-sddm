# 🌌 Caelestia SDDM Theme

A sleek, obsidian-inspired login interface designed specifically for **Caelestia**. Built with QML, this theme focuses on a minimalist "card" aesthetic, high-contrast cyan accents, and full integration with the Caelestia Shell ecosystem.

![Caelestia SDDM Preview](<https://github.com/user-attachments/assets/fbe88fda-3a4c-4570-b3b1-5a5318693165>)

## ✨ Features

* **Dynamic Gradient UI:** Deep surfaces using dynamic colors.
* **Dynamic Accents:** Interactive elements highlighted with Caelestia's dynamic primary color.
* **Glassmorphism:** Translucent central card (80% opacity) for background integration.
* **Optimized for Arch:** Lightweight QML implementation with Virtual Keyboard support.
* **Smart Fallback:** Automatically uses system avatars or falls back to the Caelestia logo.

## 🛠️ Installation

### Clone this git to ~/caelestia-sddm

`sudo cp -r ~/caelestia-sddm /usr/share/sddm/themes/caelestia`

Edit /etc/sddm.conf (or /etc/sddm.conf.d/theme.conf):

```
[Theme]
Current=caelestia
```

### To sync wallpaper and colors
```
# run the sync script
./sync.sh
```

## 🧪 TESTING- Preview the theme without logging out

`sddm-greeter --test-mode --theme /usr/share/sddm/themes/caelestia`

## 🤝 Requirements

Caelestia shell meets all the basic requirements, except for SDDM(which is a requirement or an SDDM theme).

for everyone not on Caelestia Shell:
* **SDDM** duh
* **qt6-svg**
* **qt6-virtualkeyboard**
* **JetBrains Mono Font** (preferred)
* **Rubik Font** (fallback, optional)
