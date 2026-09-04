- [x] Get the bat theme working with my grubox custom theme. Currently seeing this error: `[bat warning]: Unknown theme 'cfs-gruvbox-material', using default.` Maybe look at @~/.config/bat/themes/ ?
  - Root cause: bat's theme cache had never been built (`bat cache --build`, now also
    an install.sh step), and the theme's internal name inside the `.tmTheme` file
    didn't match the filename/config value. Fixed both; verified with `bat --list-themes`.
- [x] Remove `Pictures/Screenshots` from being tracked in asahi-dotfiles
  - Investigated: it was never actually tracked. `~/Pictures/Screenshots` lives outside
    the stow tree entirely (a plain runtime dir `screenshot.sh` mkdir -p's), and
    `git ls-files` confirms no screenshot images are in the repo. Nothing to change.
- [x] Fix/add darker highlighting to wofi so that the currently selected/active app has a darker background accent color than the rest.
  - Wired the existing (previously unused) `@bg-hover` variable into `#entry:selected`
    in wofi/style.css, using the palette's darkest tone (#141617) for a darker-than-base
    selected row.
- [x] is there a dark mode for Nautilus? It is SO white :grimace:
  - Set globally via `gsettings set org.gnome.desktop.interface color-scheme prefer-dark`
    (now also a durable install.sh step) -- but that alone wasn't enough. Nautilus
    (GTK4/libadwaita) reads the preference through the xdg-desktop-portal Settings
    interface, and the portal was never running: this session isn't systemd/UWSM-
    integrated (tty1 autologin runs `start-hyprland`, a crash-restart watchdog, not
    `uwsm start`), so `graphical-session.target` never activates and
    `xdg-desktop-portal.service` silently never starts. Fixed by starting the portal
    + gtk/hyprland backends directly in `autostart.lua` instead of depending on the
    systemd target. Takes effect on the next full Hyprland restart (logout/login or
    reboot) -- verified live this session by starting the same processes manually.
