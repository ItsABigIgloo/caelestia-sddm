# AUR Build & Contribution Guide

> [!NOTE]
> This guide is for maintainers and contributors working with the AUR package. For general usage, see [INSTALLATION.md](../INSTALLATION.md).

## Building Locally

```bash
cd aur

# Build packages locally
makepkg -scf

# Install your preferred variant
sudo pacman -U caelestia-sddm-locklike-git-*.pkg.tar.zst     # Locklike
sudo pacman -U caelestia-sddm-minimalist-git-*.pkg.tar.zst   # Minimalist
sudo pacman -U caelestia-sddm-minimalistv2-git-*.pkg.tar.zst # MinimalistV2

# Remove
sudo pacman -R caelestia-sddm-minimalist-git
```

## PKGBUILD Structure

The PKGBUILD uses a split-package approach where each theme variant conflicts with others (because they all install to `/usr/share/sddm/themes/caelestia/`).

### Adding a New Theme

1. **Update `pkgname` array:**
   ```bash
   pkgname=(
     caelestia-sddm-locklike-git
     caelestia-sddm-minimalist-git
     caelestia-sddm-minimalistv2-git
     caelestia-sddm-yourtheme-git # if adding new theme
   )
   ```

2. **Add package function:**
   ```bash
   # if adding new theme
   package_caelestia-sddm-yourtheme-git() {
     pkgdesc='Caelestia SDDM theme - yourtheme variant description'
     conflicts=('caelestia-sddm' 'caelestia-sddm-locklike-git' 'caelestia-sddm-minimalist-git' 'caelestia-sddm-minimalistv2-git')
     _package_variant 'yourtheme'
   }
   ```

3. **Update conflicts** in all existing variants to include your new one

## Testing

Before submitting to AUR:

```bash
# Build and test
makepkg -scf

# Install and test in SDDM test mode
sudo pacman -U caelestia-sddm-locklike-git-*.pkg.tar.zst
QML_XHR_ALLOW_FILE_READ=1 QT_QPA_PLATFORM=xcb sddm-greeter-qt6 --test-mode --theme /usr/share/sddm/themes/caelestia
```

## Submitting to AUR

**[Haikalllp](https://github.com/haikalllp)** and **[LeithXD](https://github.com/leithXD)** are responsible for maintaining the AUR package.
You can make a PR on your changes and they will review and update the AUR.
