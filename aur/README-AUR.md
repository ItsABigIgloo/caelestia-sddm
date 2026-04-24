# How to build using makepkg for testing

```bash
cd aur

# Build packages locally
makepkg -scf

# Install locklike
sudo pacman -U caelestia-sddm-locklike-git-*.pkg.tar.zst

# Install minimalist
sudo pacman -U caelestia-sddm-minimalist-git-*.pkg.tar.zst

# Install minimalistv2
sudo pacman -U caelestia-sddm-minimalistv2-git-*.pkg.tar.zst

# Remove an installation
sudo pacman -R caelestia-sddm-minimalist-git
```
