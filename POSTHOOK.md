# Posthook Setup

Use this if you want `sync.sh` to run automatically right after wallpaper changes (DOESNT REQUIRE REBOOT).

## 1) Configure the posthook

Edit `~/.config/caelestia/cli.json` and set:

```json
"wallpaper": {
    "postHook": "sudo /usr/share/sddm/themes/caelestia/scripts/sync.sh"
}
```

## 2) Allow passwordless sudo for this one command

Without this, posthook may fail or wait for sudo input.

Create a sudoers drop-in:

```bash
sudo visudo -f /etc/sudoers.d/caelestia-sddm-sync
```

Add this line (replace `your_username`):

```sudoers
your_username ALL=(root) NOPASSWD: /usr/share/sddm/themes/caelestia/scripts/sync.sh
```

This grants passwordless sudo only for the sync script.

## 3) Verify

Run:

```bash
sudo /usr/share/sddm/themes/caelestia/scripts/sync.sh
```

It should finish without prompting for a password.

## Notes

- This is for user-triggered posthook execution.
- The systemd service (`caelestia-sync.service`) runs separately and does not use your interactive sudo session.

## FINAL RESULT:

https://github.com/user-attachments/assets/071bdb4d-8559-4a6e-929b-d34d40a225a6

