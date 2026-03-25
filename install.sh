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

# --- 4. Install keyd (kernel-level key remapper) ---
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

# --- 5. Install Oh My Zsh Custom Plugins ---
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


# --- 6. Stow All Dotfiles ---
echo "-> Stowing all dotfiles..."
# Run stow from a subshell to avoid changing the script's current directory
(cd ~/Projects/asahi-dotfiles/ && stow -R -t $HOME */)


# --- 7. Set Zsh as Default Shell ---
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
