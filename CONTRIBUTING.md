# Contributing

Thanks for your interest in contributing to Caelestia SDDM!

## Types of Contributions

We welcome contributions for anything typically here:

### 1. Bug Fixes & General Improvements

1. Fork the repository
2. Create a branch (`git checkout -b fix/your-fixes`)
3. Make your changes
4. Run the linting and formatting tools:
   ```bash
   ./scripts/dev/lint.sh
   ./scripts/dev/format.sh -i
   ```
5. Commit and push
6. Open a Pull Request

### 2. Adding a New Theme

New themes must follow the current project structure to make sure it's compatibile with the installer, AUR packages, and Caelestia Shell integration.

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
> Have a read at [TEMPLATING.md](TEMPLATING.md) to understand how integration with Caelestia works.

### 3. AUR Package Updates

For updates to the AUR package (PKGBUILD, install script), see **[aur/README-AUR.md](aur/README-AUR.md)** for detailed instructions on building, testing, and submitting.


## Testing:

1. To Run linting:
   ```bash
   ./scripts/dev/lint.sh themes/<theme-name>/
   ```

2. To Run formatting:
   ```bash
   ./scripts/dev/format.sh -i themes/<theme-name>/
   ```

3. Test it with SDDM test mode:
   ```bash
   QML_XHR_ALLOW_FILE_READ=1 QT_QPA_PLATFORM=xcb sddm-greeter-qt6 --test-mode --theme /path/to/themes/<theme-name>
   ```


## PR Checklist

Before opening a Pull Request, make sure:

- [ ] Code passes `./scripts/dev/lint.sh`
- [ ] Code is formatted with `./scripts/dev/format.sh -i`
- [ ] Both `theme.conf` and `theme.conf.template` are present and match
- [ ] `metadata.desktop` is fully filled out
- [ ] Theme works in `sddm-greeter-qt6 --test-mode`
- [ ] For new themes: theme follows the required structure
- [ ] For AUR updates: local build tested and works

## Questions?

Feel free to open an issue or join the Caelestia community on Discord for help! - https://discord.gg/xPTAT7FFSy
