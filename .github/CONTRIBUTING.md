# Contributing

Thanks for your interest in contributing to Caelestia SDDM!

## Development Setup

The linting and formatting tools (`qmllint`/`qmlls`) read their config from `.qmlls.ini`. Copy the example to get started:

```bash
cp .qmlls.ini.example .qmlls.ini
```

> [!NOTE]
> The default `importPaths` (`/usr/lib/qt6/qml`) is for Arch. On other distributions check with `qmake6 -query QT_INSTALL_QML` and adjust `importPaths` accordingly.

## Types of Contributions

We welcome all types of contributions:

### 1. Bug Fixes & General Improvements

1. Fork the repository
2. Create a branch (`git checkout -b fix/your-fixes`)
3. Make your changes
4. Format your changes and run the checks:
   ```bash
   ./scripts/dev/format.sh
   ./scripts/dev/check-qml.sh
   ```
5. Commit and push
6. Open a Pull Request

### 2. Adding a New Theme

New themes must follow the current project structure to make sure it's compatible with the installer, AUR packages, and Caelestia Shell integration.

#### Required Structure

Your theme directory must be located at `themes/<theme-name>/` and contain the following:

```
themes/<theme-name>/
  Main.qml                      # Root QML entry point
  theme.conf                    # Runtime config with actual color values
  theme.conf.template           # Template with {{ token.hex }} placeholders
  metadata.desktop              # SDDM theme metadata
  caelestia-sddm.qmlproject     # Qt Creator project file
```
> [!TIP]
> Have a read at [Templating](TEMPLATING.md) to understand how integration with Caelestia works.

### 3. AUR Package Updates

For updates to the AUR package (PKGBUILD, install script), see **[aur/README-AUR.md](aur/README-AUR.md)** for detailed instructions on building, testing, and submitting.


## Testing:

1. To check linting and formatting:
   ```bash
   ./scripts/dev/check-qml.sh
   ```

2. To auto-format:
   ```bash
   ./scripts/dev/format.sh
   ```

3. Test it with SDDM test mode:
   ```bash
   QML_XHR_ALLOW_FILE_READ=1 QT_QPA_PLATFORM=xcb sddm-greeter-qt6 --test-mode --theme /path/to/themes/<theme-name>
   ```


## PR Checklist

Before opening a Pull Request, make sure:

- [ ] Code passes `./scripts/dev/check-qml.sh` (lint + formatting)
- [ ] Both `theme.conf` and `theme.conf.template` are present and match
- [ ] `metadata.desktop` is fully filled out
- [ ] Theme works in `sddm-greeter-qt6 --test-mode`
- [ ] For new themes: theme follows the required structure
- [ ] For AUR updates: local build tested and works

## Questions?

Feel free to open an issue or join the Caelestia community on Discord for help! - https://discord.gg/xPTAT7FFSy
