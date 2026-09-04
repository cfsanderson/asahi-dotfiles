-- Core services and startup.
-- hl.on("hyprland.start", ...) fires exactly once per Hyprland process
-- lifetime (the first render), never again on `hyprctl reload` -- this is
-- the direct replacement for exec-once.
hl.on("hyprland.start", function()
    -- xdg-desktop-portal + backends, started directly rather than relying on
    -- systemd's graphical-session.target (see the gotcha in CLAUDE.local.md,
    -- 2026-09-04: this session isn't systemd/UWSM-integrated -- tty1 autologin
    -- runs start-hyprland, a plain crash-restart watchdog, not `uwsm start` --
    -- so graphical-session.target never activates and xdg-desktop-portal.service
    -- silently never starts, which breaks the portal Settings interface that
    -- libadwaita apps like Nautilus need for dark mode). hyprland-portals.conf
    -- routes non-Hyprland-native interfaces (e.g. Settings) to the gtk backend.
    hl.dispatch(hl.dsp.exec_cmd("/usr/libexec/xdg-desktop-portal-hyprland"))
    hl.dispatch(hl.dsp.exec_cmd("/usr/libexec/xdg-desktop-portal-gtk"))
    hl.dispatch(hl.dsp.exec_cmd("/usr/libexec/xdg-desktop-portal"))

    hl.dispatch(hl.dsp.exec_cmd("mako & waybar"))
    hl.dispatch(hl.dsp.exec_cmd("swaybg -i $HOME/Pictures/Wallpapers/gruvbox-city.jpg"))
    hl.dispatch(hl.dsp.exec_cmd("lxpolkit"))

    -- Dynamic workspace-to-monitor assignment (1-5 laptop, 6-10 external)
    hl.dispatch(hl.dsp.exec_cmd("~/.config/hypr/scripts/handle-monitor.sh listen"))
    hl.dispatch(hl.dsp.exec_cmd("~/.config/hypr/scripts/handle-monitor.sh arrange"))

    -- GNOME Keyring is unlocked and started via pam_gnome_keyring.so in
    -- /etc/pam.d/login (auto_start on session open) -- no manual start needed.

    -- Clipboard (wl-clipboard installed, clipse not available on Fedora)
    -- hl.dispatch(hl.dsp.exec_cmd("wl-paste --watch wl-copy"))  -- Disabled - causes clipboard issues

    -- Start Maestral (Dropbox sync) if linked
    hl.dispatch(hl.dsp.exec_cmd("maestral start"))

    -- Idle management (hypridle -- config at ~/.config/hypr/hypridle.conf)
    hl.dispatch(hl.dsp.exec_cmd("hypridle"))
    -- hl.dispatch(hl.dsp.exec_cmd("systemctl --user start hyprpolkitagent"))
    -- hl.dispatch(hl.dsp.exec_cmd("wl-clip-persist --clipboard regular & clipse -listen"))

    -- Start protonmail-bridge before accessing aerc
    -- if it takes too much resources consider using this in the future to only load before actually starting aerc:
    -- alias mail='pgrep -x bridge || protonmail-bridge --noninteractive & sleep 2; aerc'
    hl.dispatch(hl.dsp.exec_cmd("protonmail-bridge --noninteractive"))
end)
