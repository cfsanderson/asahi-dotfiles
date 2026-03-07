# My Custom Hyprland Asahi Setup: Omarchy Inspired

So, I put Linux on my MacBook Pro...

At the beginning of last year, I tried [Omakub](https://omakub.org/) and when that was too opinionated, I tried ricing my own custom [Hyprland](https://hypr.land/) setup but got bogged down and retreated back to [Pop!_OS (Cosmic)](https://system76.com/cosmic/). When I heard about DHH's **[Omarchy](https://github.com/basecamp/omarchy)** project, I knew I had to give it a try. This configuration is heavily inspired by the principles of digital sovereignty and self-reliance championed by DHH and the Linux crowd, but I also see it as a design exercise. As a product designer, I'm constantly working within fairly narrow product constraints. What could be more liberating than building your own, bespoke digital environment??!

What started on an old 2015 MacBook Pro eventually found a better home: [Asahi Linux](https://asahilinux.org/) on my M1 MacBook Pro. Asahi's Fedora remix brings a polished, rolling-release Linux experience to Apple Silicon — and it turns out Hyprland on an M1 is genuinely great.

<details>
  <summary><b>Screenshots</b> - Click to expand</summary>

  ![Desktop background](screens/2025-08-03-211759_hyprshot.png)
  *1) Basic desktop with waybar using cfs-gruvbox-material theme*

  ![HTML Theme and Kitty](screens/2025-08-03-211717_hyprshot.png)
  *2) Example HTML theme file and Kitty terminal*

  ![Kitty with Tmux panes](screens/2025-08-03-211903_hyprshot.png)
  *3) Kitty with tmux panes and Fastfetch in theme*

  ![Btop with theme](screens/2025-08-03-211911_hyprshot.png)
  *4) btop system monitor with matching color scheme*

  ![Neovim with Claude plugin](screens/2025-08-03-211952_hyprshot.png)
  *5) Neovim with Claude plugin*

  ![Custom Bat theme](screens/2025-08-03-212003_hyprshot.png)
  *6) Custom Bat theme*

  ![RMPC](screens/2025-08-03-212012_hyprshot.png)
  *7) RMPC (need to add some music)*

  ![Claude CLI](screens/2025-08-03-212131_hyprshot.png)
  *8) Claude CLI*

</details>
</br>

This repository serves as my personal dotfiles and a self-contained toolkit for bootstrapping a new machine from a minimal Asahi Linux install to a fully configured Hyprland desktop. While Omarchy was a great gateway drug, I immediately set about customizing to my tastes — removing/replacing apps, refining with my personal theme, etc. — so much so that it just made sense to "start fresh". Here are some highlights:

## What's Inside: Core Components

### Kept from Omarchy
*   **Window Manager:** [Hyprland](https://hypr.land/)
*   **Launcher:** [Wofi](https://github.com/SimplyCEO/wofi)
*   **Bar:** [Waybar](https://github.com/Alexays/Waybar)

### Changed from Omarchy
*   **Shell:** [Zsh](https://zsh.sourceforge.io/) & [Oh My Zsh](https://ohmyz.sh/) instead of Bash
*   **Terminal:** [Kitty](https://sw.kovidgoyal.net/kitty/) instead of [Alacritty](https://alacritty.org/)
*   **Browser:** [Zen Browser](https://zen-browser.app/) instead of Chromium
*   **Neovim config:** My fork of [Kickstart.nvim](https://github.com/cfsanderson/kickstart-cfs.nvim) instead of Lazy.vim
*   **Package management:** `dnf` + Flatpak + COPR instead of `pacman` + AUR

### Added
*   **Install Script:** Uses a declarative package list to make setting up a new system reproducible and fast
*   **Dotfile Management:** [GNU Stow](https://www.gnu.org/software/stow/)
*   **Music:** [MPD](https://www.musicpd.org/) + [rmpc](https://github.com/mierak/rmpc) for music playback with a gruvbox-material themed TUI client
*   **Calendar:** [khal](https://khal.readthedocs.io/) + [vdirsyncer](https://github.com/pimutils/vdirsyncer) for a terminal calendar with iCloud CalDAV sync and Strava training calendar subscription
*   **Color Scheme:** My fork of [Sainnhe's Gruvbox Material](https://github.com/cfsanderson/cfs-gruvbox-material) for theming
	* Includes a **master color palette system** in `colors/` directory with CSS and shell variables for consistent theming
	* All applications use exact colors from the Neovim theme for perfect visual consistency
	* No fancy theme switching options like Omarchy but the configs for theming are more transparent and easily configurable (feature, not a bug IMO)

---

## Fresh Installation Workflow

### Phase 0: Preparation

1. **Back up your Mac** (just in case — the Asahi installer is non-destructive but better safe than sorry)
2. **Check compatibility:** Visit [asahilinux.org](https://asahilinux.org/) to confirm your Apple Silicon chip is supported. M1/M2/M3 series all work well.

---

### Phase 1: Install Asahi Linux

Asahi provides a one-liner installer that runs from macOS. It resizes your APFS partition and sets up a Fedora Linux environment alongside macOS.

1. **Run the Asahi installer** from macOS Terminal:
    ```bash
    curl https://alx.sh | sh
    ```
2. **Select Fedora Asahi Remix** (the default desktop option) when prompted
3. **Follow the prompts** — the installer guides you through partitioning and setup
4. **Reboot** into Fedora when the installer completes

---

### Phase 2: First Boot Setup

After booting into Fedora Asahi for the first time:

1. **Connect to Wi-Fi:**
    ```bash
    nmtui
    ```
2. **Update the system:**
    ```bash
    sudo dnf upgrade -y
    ```
3. **Install git and stow** if not already present:
    ```bash
    sudo dnf install -y git stow
    ```

---

### Phase 3: Deploy Custom Environment

1. **Create the Monitor Configuration:**
    Before stowing, you must create a machine-specific monitor configuration. Hyprland will not start correctly without it.
    ```bash
    mkdir -p ~/.config/hypr
    nvim ~/.config/hypr/monitors.conf
    ```
    Run `hyprctl monitors` to find your monitor names. See the [Hyprland monitor docs](https://wiki.hypr.land/Configuring/Monitors/) for syntax.

2. **Clone this repository (with submodules):**
    ```bash
    git clone --recurse-submodules https://github.com/cfsanderson/asahi-dotfiles.git ~/Projects/asahi-dotfiles
    ```

3. **Run the automated install script:**
    This enables COPR repos, installs DNF packages, installs Flatpak apps, and stows all dotfiles.
    ```bash
    cd ~/Projects/asahi-dotfiles
    ./install.sh
    ```

---

### Phase 4: Manual System Configuration

These steps require `sudo` and modify system files in `/etc`. They must be done manually after the main install script completes.

**Copy system-level configurations from the repo:**
```bash
sudo cp -r ~/Projects/asahi-dotfiles/etc/* /etc/
```

---

### Phase 5: Asahi-Specific Notes

A few quirks specific to running Linux on Apple Silicon hardware:

**Peripheral boot limitation:** USB-C dongles and HDMI monitors must be plugged in **after boot**, not before. U-Boot's XHCI driver hangs on multi-function USB hubs, and the DCP DP2HDMI bridge fails to initialize external displays at boot. Both work fine when hot-plugged after the desktop loads.

**External display:** The included monitor config targets a Dell U2720QM 4K via HDMI, bottom-edge aligned with the internal display (the shorter laptop display is offset downward so the bases line up). Workspaces are dynamically assigned: laptop-only gets all 10; plugging in the external monitor moves workspaces 6–10 to it automatically via `scripts/handle-monitor.sh`.

---

### Post-Install

- Open Neovim for the first time (`nvim`) and `lazy.nvim` will automatically install all plugins. Close and reopen to see everything initialized.
- The `install.sh` script installs everything from the `packages/` directory. When you add more software, use the `fedorapack` alias to rebuild the package lists and keep them up to date.
  - Generates `packages-dnf.txt` (user-installed DNF packages), `packages-flatpak.txt` (Flatpak apps), and `packages-copr.txt` (enabled COPR repos)
- **Calendar setup:** Add credentials to `~/.config/zsh/.env.local` (`ICLOUD_EMAIL`, `ICLOUD_APP_PASSWORD`, `STRAVA_CALENDAR_URL`), then run `vdirsyncer discover && vdirsyncer sync` and enable the timer: `systemctl --user enable --now vdirsyncer.timer`

---

## Customizing Colors and Themes

This setup includes a comprehensive master color palette system for easy customization:

- **Master Palette Files:** Located in `colors/` directory
  - `gruvbox-material-palette.css` - CSS variables for waybar and web-based configs
  - `gruvbox-material-wofi.css` - GTK color definitions for wofi
  - `gruvbox-material-mako.conf` - Color template for mako notifications
  - `gruvbox-material-palette.toml` - TOML color values for yazi, starship, etc.
  - `gruvbox-material-palette.sh` - Shell variables for scripts and configs
  - `color-preview.html` - Interactive color reference tool
  - `README.md` - Complete documentation and usage examples

- **Customization Workflow:**
  1. Modify colors in the master palette files
  2. Re-stow configs with the `stowr` alias
  3. Restart applications to see changes
  4. All applications automatically inherit the new colors

- **Supported Applications:** Waybar (CSS variables), Wofi (GTK colors), Mako (template), Hyprland, Hyprlock, rmpc, and more all use the master palette for perfect consistency

See `colors/README.md` for detailed documentation on customizing colors and adding support to new applications.
