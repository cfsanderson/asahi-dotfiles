-- Core services and startup.
-- hl.on("hyprland.start", ...) fires exactly once per Hyprland process
-- lifetime (the first render), never again on `hyprctl reload` -- this is
-- the direct replacement for exec-once.
hl.on("hyprland.start", function()
    hl.dispatch(hl.dsp.exec_cmd("mako & waybar"))
    hl.dispatch(hl.dsp.exec_cmd("swaybg -i $HOME/Pictures/Wallpapers/gruvbox-city.jpg"))
    hl.dispatch(hl.dsp.exec_cmd("lxpolkit"))

    -- Dynamic workspace-to-monitor assignment (1-5 laptop, 6-10 external)
    hl.dispatch(hl.dsp.exec_cmd("~/.config/hypr/scripts/handle-monitor.sh listen"))
    hl.dispatch(hl.dsp.exec_cmd("~/.config/hypr/scripts/handle-monitor.sh arrange"))

    -- GNOME Keyring (auto-unlock secrets at login)
    hl.dispatch(hl.dsp.exec_cmd("gnome-keyring-daemon --start --components=secrets"))

    -- Clipboard (wl-clipboard installed, clipse not available on Fedora)
    -- hl.dispatch(hl.dsp.exec_cmd("wl-paste --watch wl-copy"))  -- Disabled - causes clipboard issues

    -- Terminal on workspace 10, spawned straight onto that workspace and fullscreen
    hl.dispatch(hl.dsp.exec_cmd("kitty -e tmux new-session", { workspace = "10", fullscreen = true }))
    hl.dispatch(hl.dsp.exec_cmd("sleep 3 && hyprctl dispatch workspace 10"))

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
