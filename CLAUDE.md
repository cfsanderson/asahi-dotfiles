# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal dotfiles repository for Fedora Asahi Linux (Apple Silicon) that provides a complete Hyprland desktop environment setup. It's inspired by DHH's Omarchy project but customized with personal preferences. The repository uses GNU Stow for dotfile management and includes an automated installation script.

## Key Commands

### Installation and Setup
- `./install.sh` - Main installation script that installs packages, plugins, and stows all dotfiles
- `fedorapack` - Alias to rebuild package lists (updates packages-dnf.txt, packages-flatpak.txt, packages-copr.txt)
- `stowr` - Alias to re-stow all dotfiles: `cd ~/Projects/asahi-dotfiles/ && stow -R -t $HOME */`

### Package Management
- Package lists are stored in `packages/packages-dnf.txt` (dnf), `packages/packages-flatpak.txt` (Flatpak), and `packages/packages-copr.txt` (COPR repos)
- Use `sudo dnf install -y $(cat packages/packages-dnf.txt)` to install DNF packages
- Use `flatpak install -y flathub <app-id>` to install Flatpak apps
- Use `sudo dnf copr enable -y <owner/repo>` to enable COPR repositories

### Configuration Shortcuts (via aliases)
- `confhypr` - Edit Hyprland configs: `cd hyprland/.config/hypr/ && nvim .`
- `confnv` - Edit Neovim config: `cd nvim/.config/nvim/ && nvim init.lua`
- `conftmux` - Edit Tmux config: `cd tmux/.config/tmux/ && nvim .`
- `confkitty` - Edit Kitty terminal config: `cd kitty/.config/kitty/ && nvim .`
- `confalias` - Edit shell aliases: `cd zsh/.config/zsh/oh-my-zsh/custom/ && nvim aliases.zsh`
- `confzsh` - Edit Zsh main config: `cd ~/.config/zsh/ && nvim .zshrc`
- `music` - Launch rmpc music player (stops MPD on exit)
- `cal` - Open khal interactive calendar TUI (syncs on exit)
- `calday` - List upcoming calendar events

## Architecture

### Dotfile Organization
The repository uses GNU Stow's directory structure where each top-level directory represents a package:
- `hyprland/` - Window manager configuration (modular config split across multiple files)
- `nvim/` - Neovim configuration (fork of Kickstart.nvim)
- `zsh/` - Shell configuration with Oh My Zsh
- `kitty/` - Terminal emulator configuration
- `waybar/` - Status bar configuration
- `wofi/` - Application launcher configuration
- `tmux/` - Terminal multiplexer configuration
- `mako/` - Notification daemon configuration
- `btop/` - System monitor configuration
- `fastfetch/` - System info display configuration
- `mpd/` - Music Player Daemon configuration (PipeWire output, localhost)
- `rmpc/` - rmpc MPD TUI client config + gruvbox-material theme (`themes/gruvbox.ron`)
- `khal/` - Calendar TUI configuration (gruvbox-material themed palette)
- `vdirsyncer/` - Calendar sync (iCloud CalDAV + Strava HTTP) with systemd timer
- `packages/` - Package lists for reproducible installs
- `etc/` - System-level configurations (requires manual copying to /etc/)
- `wallpapers/` - Desktop wallpapers

### Hyprland Configuration Structure
Hyprland config is Lua (`hyprland.lua`), not hyprlang `.conf` — migrated 2026-08-22 because
hyprlang/`.conf` support is dropped in Hyprland 0.57 (this repo tracks 0.56.2). Modularized
across multiple files in `hyprland/.config/hypr/`, `require()`d from `hyprland.lua`:
- `hyprland.lua` - Main config file; defines shared app-launcher globals ($terminal etc.
  become plain Lua globals since `require()`d files don't share `local` scope) and
  `require()`s all others, in the same order the old `source=` lines used
- `monitors.lua` - Machine-specific monitor configuration (must be created manually)
- `autostart.lua` - Apps to start with Hyprland, via `hl.on("hyprland.start", function() ... end)`
  (fires exactly once per Hyprland process — the exec-once equivalent)
- `bindings.lua` - Keyboard shortcuts and bindings (`hl.bind(...)`)
- `envs.lua` - Environment variables (`hl.env(...)`)
- `input.lua` - Input device configuration
- `windows.lua` - Window/layer rules (`hl.window_rule(...)` / `hl.layer_rule(...)`)
- `theme.lua` - Color scheme and theming
- `scripts/` - Helper scripts (e.g., launch-wofi.sh, handle-monitor.sh)

The old `hyprland.conf` + `*.conf` files are still present, untouched, as a fallback: Hyprland
prefers `hyprland.lua` when present and only falls back to the legacy `.conf` parser if it's
missing, so deleting `hyprland.lua` is an instant rollback.

**Lua config gotchas** (learned migrating this repo — see git log for the fixes):
- Old hyprlang key names with hyphens or colons get auto-translated for `hl.config()`
  lookups: `:` → `.`, `-` → `_`. So old `tap-to-click` is `tap_to_click` in Lua, not a
  bracket-string `["tap-to-click"]`.
- Under Lua config mode, `hyprctl dispatch <args>` evaluates its argument as a Lua
  expression (auto-wrapped in `hl.dispatch(...)`) — NOT the old `dispatch <name> <args>`
  string form. Any script calling `hyprctl dispatch <dispatcher> <args>` (e.g.
  `handle-monitor.sh`) must be rewritten to `hyprctl dispatch 'hl.dsp.<dispatcher>({...})'`.
- The Lua config manager type (Lua vs. legacy) is decided once at Hyprland process startup
  based on whether `hyprland.lua` exists at that moment — `hyprctl reload` re-parses
  whichever manager is already loaded, it does NOT re-check which file to use. A fresh
  Hyprland start (logout/login or reboot) is required to actually pick up `hyprland.lua`
  for the first time.

### Key Applications
- **Window Manager**: Hyprland (Wayland compositor)
- **Terminal**: Kitty (replaces Alacritty from Omarchy)
- **Shell**: Zsh with Oh My Zsh
- **Browser**: Brave (configured for Wayland)
- **Editor**: Neovim (Kickstart.nvim fork)
- **Launcher**: Wofi
- **Bar**: Waybar
- **File Manager**: Nautilus
- **Notifications**: Mako
- **Music**: MPD + rmpc (TUI client, gruvbox-themed; `music` alias stops playback on exit)
- **Calendar**: khal + vdirsyncer (iCloud CalDAV sync, Strava training calendar)

### Theme
Uses a custom fork of Sainnhe's Gruvbox Material theme for consistent theming across applications.

## Critical Setup Requirements

1. **Monitor Configuration**: Before stowing configs, create `~/.config/hypr/monitors.conf` with machine-specific monitor settings. Use `hyprctl monitors` to find monitor names. The included config has the M1 Max MacBook Pro internal display and Dell U2720QM 4K via HDMI, bottom-edge aligned (the shorter laptop display is offset downward so the bases line up). See the [Hyprland monitor docs](https://wiki.hypr.land/Configuring/Monitors/) for position syntax. Workspaces are dynamically assigned: laptop-only gets all 10, plugging in the external monitor moves workspaces 6-10 to it (handled by `scripts/handle-monitor.sh` via Hyprland IPC socket events).

5. **Peripheral Boot Limitation (Asahi Linux)**: USB-C dongles and HDMI monitors must be plugged in **after boot**, not before. U-Boot's XHCI driver hangs on multi-function USB hubs, and the DCP DP2HDMI bridge fails to initialize external displays at boot. Both work fine when hot-plugged after the desktop loads.

2. **Manual System Configuration**: After running `install.sh`, system-level configs in `etc/` must be manually copied to `/etc/` with sudo privileges.

3. **Shell Change**: The install script will change the default shell to Zsh if not already set.

4. **Calendar Setup**: After stowing, add credentials to `~/.config/zsh/.env.local`:
   - `ICLOUD_EMAIL` - Apple ID email
   - `ICLOUD_APP_PASSWORD` - App-specific password from appleid.apple.com
   - `STRAVA_CALENDAR_URL` - Full URL to Raspberry Pi calendar server (e.g. `http://<PI_IP>:8080/training_calendar.ics`)
   - Then run `vdirsyncer discover && vdirsyncer sync` and enable the timer: `systemctl --user enable --now vdirsyncer.timer`

## Development Workflow

When modifying this dotfiles setup:
1. Make changes to files in the appropriate package directory
2. Test changes by re-stowing: `stowr`
3. Update package lists when adding new software: `fedorapack`
4. The Neovim config includes a CLAUDE.md specific to that configuration

## Session History Tracking

**IMPORTANT**: Claude Code should maintain `CLAUDE.local.md` to track significant changes and conclusions from each session. This file is git-ignored and should be updated whenever:
- Significant changes are made to the dotfiles configuration
- New features or workflows are implemented
- Issues are resolved or configurations are fixed
- Sessions reach important conclusions or milestones

This helps maintain continuity between sessions and provides a record of what has been accomplished.

### Secrets Management
- **Tracked configs** contain no PII or credentials — all secrets are fetched at runtime from environment variables
- **`~/.config/zsh/.env.local`** (gitignored) stores sensitive env vars, sourced by `.zshrc`
- **`~/.config/zsh/oh-my-zsh/custom/local.zsh`** (gitignored) stores sensitive aliases
- vdirsyncer uses `command` fetch to read env vars (`username.fetch`, `password.fetch`, `url.fetch`)

## Notes

- This setup runs on Fedora Asahi Linux on an Apple Silicon MacBook Pro
- The repository includes submodules (use `git clone --recurse-submodules` when cloning)
- Wi-Fi connection after install: use `nmtui` for first-time connection
- Package management uses dnf (Fedora repos + COPR) and Flatpak