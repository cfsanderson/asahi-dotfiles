#!/bin/bash

# Terminate any already running wofi instances
killall -q wofi

# Ensure Flatpak app entries are visible even if the session env is stale
# (Hyprland envs.conf sets this too; this line makes it work without a relogin)
export XDG_DATA_DIRS="$HOME/.local/share/flatpak/exports/share:/var/lib/flatpak/exports/share:${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"

# Launch a new wofi instance with config
wofi --show drun --sort-order=alphabetical --style=$HOME/.config/wofi/style.css

