# How to build using pkgbuild

```bash
cd aur

# Build pakages locally
makepkg -sf

# Install locklike
sudo pacman -U caelestia-sddm-locklike-git-*.pkg.tar.zst

# Install minimalist
sudo pacman -U caelestia-sddm-minimalistv2-git-*.pkg.tar.zst

# Install minimalistv2
sudo pacman -U caelestia-sddm-minimalist-git-*.pkg.tar.zst

# Remove an installation
sudo pacman -R caelestia-sddm-minimalist-git
```