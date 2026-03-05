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
- `confghostty` - Edit Ghostty terminal config: `cd ghostty/.config/ghostty/ && nvim config`
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
- `ghostty/` - Terminal emulator configuration
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
Hyprland config is modularized across multiple files in `hyprland/.config/hypr/`:
- `hyprland.conf` - Main config file that sources all others
- `monitors.conf` - Machine-specific monitor configuration (must be created manually)
- `autostart.conf` - Applications to start with Hyprland
- `bindings.conf` - Keyboard shortcuts and bindings
- `envs.conf` - Environment variables
- `input.conf` - Input device configuration
- `looknfeel.conf` - Appearance and animation settings
- `windows.conf` - Window rules and workspace settings
- `theme.conf` - Color scheme and theming
- `scripts/` - Helper scripts (e.g., launch-wofi.sh, handle-monitor.sh)

### Key Applications
- **Window Manager**: Hyprland (Wayland compositor)
- **Terminal**: Ghostty (replaces Alacritty from Omarchy)
- **Shell**: Zsh with Oh My Zsh
- **Browser**: Zen Browser (configured for Wayland)
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