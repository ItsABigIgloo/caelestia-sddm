# 🌌 Caelestia SDDM Theme

A sleek, obsidian-inspired login interface designed specifically for **Caelestia**. Built with QML, this theme focuses on a minimalist "card" aesthetic, high-contrast cyan accents, and full integration with the Caelestia Shell ecosystem.

![Caelestia SDDM Preview](<https://github.com/user-attachments/assets/fbe88fda-3a4c-4570-b3b1-5a5318693165>)

## ✨ Features

* **Obsidian UI:** Deep surfaces using `#131313` for a true dark-mode experience.
* **Cyan Accents:** Interactive elements highlighted with Caelestia Cyan (`#4cdadb`).
* **Glassmorphism:** Translucent central card (80% opacity) for background integration.
* **Optimized for Arch:** Lightweight QML implementation with Virtual Keyboard support.
* **Smart Fallback:** Automatically uses system avatars or falls back to the Caelestia logo.

## 🛠️ Installation

### The Quick Way (Recommended)
Clone the repository and run the automated install script:

```bash
git clone https://github.com/ItsABigIgloo/caelestia-sddm.git
cd caelestia-sddm
chmod +x install.sh
./install.sh
```
### The Longer Way (Too cool for scripts)
`sudo cp -r ~/projects/caelestia-sddm /usr/share/sddm/themes/caelestia`
Edit /etc/sddm.conf (or /etc/sddm.conf.d/theme.conf):
```
[Theme]
Current=caelestia
```

## 🧪 TESTING- Preview the theme without logging out

`sddm-greeter --test-mode --theme /usr/share/sddm/themes/caelestia`

## 🤝 Requirements

Caelestia shell meets all the basic requirements, don't you worry!

for everyone not on Caelestia Shell:
* **SDDM** duh
* **qt6-svg**
* **qt6-virtualkeyboard**
* **Rubik Font**
