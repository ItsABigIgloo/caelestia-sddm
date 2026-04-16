# Posthook Setup

Use this if you want `sync.sh` to run automatically right after wallpaper changes (DOESNT REQUIRE REBOOT).

## 1) Configure the posthook

Edit `~/.config/caelestia/cli.json` and set:

```json
"wallpaper": {
    "postHook": "sudo /usr/share/sddm/themes/caelestia/scripts/sync.sh --posthook"
}
```
If you dont have `cli.json` file setup, get them from (Under "Example Configuration"):

[https://github.com/caelestia-dots/cli](https://github.com/caelestia-dots/cli#configuring)

Simply copy it and paste the content to `~/.config/caelestia/cli.json`.

## 2) Allow passwordless sudo for this one command

Without this, posthook will fail because it waits for sudo input.

Create a sudoers drop-in:

```bash
export EDITOR=nano && sudo -E visudo -f /etc/sudoers.d/caelestia-sddm-sync
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

<video src="https://github.com/user-attachments/assets/e16d6576-2bb8-49d4-9de5-48f44926f04b
" width="" controls autoplay loop>
</video>
