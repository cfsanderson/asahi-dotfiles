hl.on("hyprland.start", function()
    -- Core services
    hl.exec_cmd("mako & waybar")
    hl.exec_cmd("swaybg -i $HOME/Pictures/Wallpapers/gruvbox-city.jpg")
    hl.exec_cmd("lxpolkit")

    -- Dynamic workspace-to-monitor assignment (1-5 laptop, 6-10 external)
    hl.exec_cmd("~/.config/hypr/scripts/handle-monitor.sh listen")
    hl.exec_cmd("~/.config/hypr/scripts/handle-monitor.sh arrange")

    -- GNOME Keyring (auto-unlock secrets at login)
    hl.exec_cmd("gnome-keyring-daemon --start --components=secrets")

    -- Clipboard (wl-clipboard installed, clipse not available on Fedora)
    -- hl.exec_cmd("wl-paste --watch wl-copy")  -- Disabled - causes clipboard issues

    -- Start Maestral (Dropbox sync) if linked
    hl.exec_cmd("maestral start")

    -- Idle management (hypridle — config at ~/.config/hypr/hypridle.conf)
    hl.exec_cmd("hypridle")
    -- hl.exec_cmd("systemctl --user start hyprpolkitagent")
    -- hl.exec_cmd("wl-clip-persist --clipboard regular & clipse -listen")

    -- Start protonmail-bridge before accessing aerc
    -- if it takes too much resources consider using this in the future to only load before actually starting aerc:
    -- alias mail='pgrep -x bridge || protonmail-bridge --noninteractive & sleep 2; aerc'
    hl.exec_cmd("protonmail-bridge --noninteractive")
end)
