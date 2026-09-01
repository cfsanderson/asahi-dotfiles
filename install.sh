#!/bin/bash
#
# Fedora Asahi Linux Bootstrap Script
# This script installs all packages, plugins, and dotfiles (https://github.com/cfsanderson/asahi-dotfiles/)
#

# Exit immediately if a command exits with a non-zero status.
set -e

echo "--- Starting Fedora Asahi Setup ---"

# --- 1. Enable COPR Repositories ---
echo "-> Enabling COPR repositories from packages-copr.txt..."
while IFS= read -r repo; do
    [[ -z "$repo" || "$repo" == \#* ]] && continue
    sudo dnf copr enable -y "$repo"
done < packages/packages-copr.txt

# --- 2. Install DNF Packages ---
echo "-> Installing DNF packages from packages-dnf.txt..."
sudo dnf install -y --skip-unavailable $(grep -v '^\s*#' packages/packages-dnf.txt | grep -v '^\s*$')

# --- 3. Install Flatpak Apps ---
echo "-> Installing Flatpak apps from packages-flatpak.txt..."
while IFS= read -r app; do
    [[ -z "$app" || "$app" == \#* ]] && continue
    flatpak install -y flathub "$app" 2>/dev/null || echo "   Note: $app may need a custom remote"
done < packages/packages-flatpak.txt

# --- 4. Install Nerd Fonts (FiraCode, CascadiaMono) ---
# Not packaged in Fedora's repos under these names; waybar/kitty configs
# both reference "FiraCode Nerd Font" / "CaskaydiaMono Nerd Font" by exact
# family name, so pull the patched fonts straight from upstream.
NERD_FONTS_VERSION="v3.5.1"
if ! fc-list | grep -qi "FiraCode Nerd Font"; then
    echo "-> Installing FiraCode Nerd Font..."
    mkdir -p /tmp/nerdfonts ~/.local/share/fonts/FiraCodeNerdFont
    curl -fL -o /tmp/nerdfonts/FiraCode.zip "https://github.com/ryanoasis/nerd-fonts/releases/download/${NERD_FONTS_VERSION}/FiraCode.zip"
    unzip -o -q /tmp/nerdfonts/FiraCode.zip -d /tmp/nerdfonts/FiraCode "*.ttf"
    cp /tmp/nerdfonts/FiraCode/*.ttf ~/.local/share/fonts/FiraCodeNerdFont/
else
    echo "   FiraCode Nerd Font already installed, skipping."
fi
if ! fc-list | grep -qi "CaskaydiaMono Nerd Font"; then
    echo "-> Installing CaskaydiaMono Nerd Font..."
    mkdir -p /tmp/nerdfonts ~/.local/share/fonts/CascadiaMonoNerdFont
    curl -fL -o /tmp/nerdfonts/CascadiaMono.zip "https://github.com/ryanoasis/nerd-fonts/releases/download/${NERD_FONTS_VERSION}/CascadiaMono.zip"
    unzip -o -q /tmp/nerdfonts/CascadiaMono.zip -d /tmp/nerdfonts/CascadiaMono "*.ttf"
    cp /tmp/nerdfonts/CascadiaMono/*.ttf ~/.local/share/fonts/CascadiaMonoNerdFont/
else
    echo "   CaskaydiaMono Nerd Font already installed, skipping."
fi
rm -rf /tmp/nerdfonts
fc-cache -f ~/.local/share/fonts >/dev/null 2>&1

# --- 5. Install yazi (TUI file manager) ---
# Not packaged in Fedora's repos and no cargo toolchain assumed here, so
# pull the official prebuilt aarch64-linux-gnu binaries straight from
# upstream, same pattern as the Nerd Fonts step above.
YAZI_VERSION="v26.8.15"
if ! command -v yazi &>/dev/null; then
    echo "-> Installing yazi..."
    mkdir -p /tmp/yazi ~/.local/bin
    curl -fL -o /tmp/yazi/yazi.zip "https://github.com/sxyazi/yazi/releases/download/${YAZI_VERSION}/yazi-aarch64-unknown-linux-gnu.zip"
    unzip -o -q /tmp/yazi/yazi.zip "*/yazi" "*/ya" -d /tmp/yazi
    cp /tmp/yazi/yazi-aarch64-unknown-linux-gnu/yazi /tmp/yazi/yazi-aarch64-unknown-linux-gnu/ya ~/.local/bin/
    chmod +x ~/.local/bin/yazi ~/.local/bin/ya
    rm -rf /tmp/yazi
else
    echo "   yazi already installed, skipping."
fi

# --- 6. Install keyd (kernel-level key remapper) ---
echo "-> Installing keyd from source..."
if ! command -v keyd &>/dev/null; then
    git clone https://github.com/rvaiya/keyd /tmp/keyd
    make -C /tmp/keyd
    sudo make -C /tmp/keyd install
    rm -rf /tmp/keyd
else
    echo "   keyd already installed, skipping."
fi
echo "-> Copying keyd config and enabling service..."
sudo mkdir -p /etc/keyd
sudo cp etc/keyd/default.conf /etc/keyd/default.conf
sudo systemctl enable --now keyd

# --- 7. Install Maestral (Dropbox client) ---
# Official Dropbox has no Linux ARM64 build, so this repo uses Maestral (an
# open-source client) instead -- autostart.lua and waybar's custom/dropbox
# module both already assume `maestral` is on PATH. Installed via pipx since
# Fedora's system Python is externally-managed (PEP 668).
echo "-> Installing Maestral (Dropbox client)..."
if ! command -v maestral &>/dev/null; then
    pipx install maestral
else
    echo "   Maestral already installed, skipping."
fi
echo "   NOTE: Maestral still needs to be linked to your Dropbox account --"
echo "   run 'maestral auth' interactively after this script finishes."

# --- 8. Install Oh My Zsh Custom Plugins ---
echo "-> Installing custom Oh My Zsh plugins..."
# The destination needs to be the live directory, not the stowed one
ZSH_CUSTOM="$HOME/.config/zsh/oh-my-zsh/custom"

# Check if the directories exist before cloning
if [ ! -d "${ZSH_CUSTOM}/plugins/zsh-completions" ]; then
    git clone https://github.com/zsh-users/zsh-completions "${ZSH_CUSTOM}/plugins/zsh-completions"
fi

if [ ! -d "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting"
fi


# --- 9. Stow All Dotfiles ---
echo "-> Stowing all dotfiles..."
# Pre-create ~/Pictures as a REAL directory before stowing. The `wallpapers`
# package is the only one under ~/Pictures, so without this stow folds the
# whole tree into a single symlink (~/Pictures -> repo/wallpapers/Pictures) and
# anything an app writes there (e.g. screenshot.sh's ~/Pictures/Screenshots)
# lands inside the repo checkout. A real ~/Pictures with a real subdir in it
# blocks the fold, so only ~/Pictures/Wallpapers gets symlinked.
mkdir -p "$HOME/Pictures/Screenshots"
# Run stow from a subshell to avoid changing the script's current directory
(cd ~/Projects/asahi-dotfiles/ && stow -R -t $HOME */)

# --- 10. Materialize systemd user unit files (not stow-symlinked) ---
echo "-> Copying systemd user units into place (not symlinked -- see CLAUDE.md)..."
# Systemd requires a unit file's REAL location (after resolving symlinks) to be
# inside a standard search path, or it treats it as "linked" rather than
# "enabled" and silently excludes it from a target's boot-time dependency
# closure -- even with a valid *.wants/ symlink present. Stow-symlinking unit
# files breaks this (confirmed 2026-08-25: vdirsyncer.timer and the Hermes
# gateway/signal-cli-daemon units never actually started at boot despite
# `systemctl enable` reporting success). Fix: copy the real bytes into
# ~/.config/systemd/user/ instead of relying on stow's symlink for this one
# subdirectory. Source of truth stays in the repo; re-run this block (or the
# whole install.sh) after editing a tracked unit file.
mkdir -p ~/.config/systemd/user
for pkg_unit_dir in ~/Projects/asahi-dotfiles/*/.config/systemd/user; do
    [ -d "$pkg_unit_dir" ] || continue
    for unit_file in "$pkg_unit_dir"/*.service "$pkg_unit_dir"/*.timer; do
        [ -f "$unit_file" ] || continue
        cp "$unit_file" ~/.config/systemd/user/
    done
done
systemctl --user daemon-reload

# --- 11. Enable MPD (Music Player Daemon) ---
echo "-> Enabling MPD service..."
mkdir -p ~/Music
systemctl --user enable --now mpd

# --- 12. Install TPM (Tmux Plugin Manager) and Plugins ---
echo "-> Installing Tmux Plugin Manager..."
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
else
    echo "   TPM already installed, skipping clone."
fi

echo "-> Installing tmux plugins (gruvbox theme, yank, navigator, sensible)..."
# install_plugins.sh reads @plugin entries from a running tmux server's options,
# which are only registered once tmux.conf's `run '~/.tmux/plugins/tpm/tpm'`
# line has been sourced -- so spin up a throwaway detached session to source
# the (now-stowed) config, then run the installer against it.
tmux new-session -d -s __tpm_bootstrap
tmux source-file "$HOME/.config/tmux/tmux.conf"
"$HOME/.tmux/plugins/tpm/scripts/install_plugins.sh"
tmux kill-session -t __tpm_bootstrap


# --- 13. Set Zsh as Default Shell ---
if [ "$SHELL" != "/bin/zsh" ]; then
  echo "-> Changing default shell to Zsh..."
  chsh -s $(which zsh)
else
  echo "-> Shell is already Zsh."
fi


echo ""
echo "--- Automated Setup Complete! ---"
echo "Please review the README.md for required MANUAL system configurations."
echo "A reboot is required to apply all changes."
