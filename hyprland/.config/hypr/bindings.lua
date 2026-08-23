-- See https://wiki.hypr.land/Configuring/Basics/Binds/

-- bind = SUPER SHIFT, R, exec, ~/.config/hypr/scripts/reload.sh  -- TODO: create reload.sh script
hl.bind("SUPER + P", hl.dsp.exec_cmd(passwordManager))

-- Start default apps
hl.bind("SUPER + Return", hl.dsp.exec_cmd(terminal))
hl.bind("SUPER + F", hl.dsp.exec_cmd(fileManager))
hl.bind("SUPER + B", hl.dsp.exec_cmd(browser))
hl.bind("SUPER + C", hl.dsp.exec_cmd(claude))
hl.bind("SUPER + M", hl.dsp.exec_cmd(mail))
hl.bind("SUPER + N", hl.dsp.exec_cmd(terminal .. " -e nvim"))
hl.bind("SUPER + T", hl.dsp.exec_cmd(terminal))
hl.bind("SUPER + D", hl.dsp.exec_cmd(terminal .. " -e lazydocker"))
hl.bind("SUPER + G", hl.dsp.exec_cmd(messenger))
hl.bind("SUPER + S", hl.dsp.exec_cmd("signal-desktop"))
hl.bind("SUPER + O", hl.dsp.exec_cmd("flatpak run md.obsidian.Obsidian --force-device-scale-factor=2"))
hl.bind("SUPER + slash", hl.dsp.exec_cmd(passwordManager))

hl.bind("SUPER + space", hl.dsp.exec_cmd("$HOME/.config/hypr/scripts/launch-wofi.sh"))
hl.bind("SUPER + SHIFT + SPACE", hl.dsp.exec_cmd("pkill -SIGUSR1 waybar"))
-- bind = SUPER CTRL, SPACE, exec, ~/.local/share/omarchy/bin/swaybg-next  -- omarchy not installed
-- bind = SUPER SHIFT CTRL, SPACE, exec, ~/.local/share/omarchy/bin/omarchy-theme-next  -- omarchy not installed

hl.bind("SUPER + W", hl.dsp.window.close())

-- Go Fullscreen
hl.bind("F11", hl.dsp.window.fullscreen())

-- End active session
hl.bind("SUPER + ESCAPE", hl.dsp.exec_cmd("hyprlock"))
hl.bind("SUPER + SHIFT + ESCAPE", hl.dsp.exec_cmd("systemctl suspend"))
hl.bind("SUPER + ALT + ESCAPE", hl.dsp.exit())
hl.bind("SUPER + CTRL + ESCAPE", hl.dsp.exec_cmd("reboot"))
hl.bind("SUPER + SHIFT + CTRL + ESCAPE", hl.dsp.exec_cmd("systemctl poweroff"))

-- Control tiling
hl.bind("SUPER + semicolon", hl.dsp.layout("togglesplit"))
hl.bind("SUPER + P", hl.dsp.window.pseudo()) -- dwindle
hl.bind("SUPER + V", hl.dsp.window.float({ action = "toggle" }))

-- Move focus with mainMod + arrow keys
hl.bind("SUPER + h", hl.dsp.focus({ direction = "left" }))
hl.bind("SUPER + l", hl.dsp.focus({ direction = "right" }))
hl.bind("SUPER + k", hl.dsp.focus({ direction = "up" }))
hl.bind("SUPER + j", hl.dsp.focus({ direction = "down" }))

-- Switch workspaces with mainMod + [0-9]
-- Uses handle-monitor.sh to focus the correct monitor first (1-5 laptop, 6-10 external)
local switchWs = "~/.config/hypr/scripts/handle-monitor.sh switch"
hl.bind("SUPER + 1", hl.dsp.exec_cmd(switchWs .. " 1"))
hl.bind("SUPER + 2", hl.dsp.exec_cmd(switchWs .. " 2"))
hl.bind("SUPER + 3", hl.dsp.exec_cmd(switchWs .. " 3"))
hl.bind("SUPER + 4", hl.dsp.exec_cmd(switchWs .. " 4"))
hl.bind("SUPER + 5", hl.dsp.exec_cmd(switchWs .. " 5"))
hl.bind("SUPER + 6", hl.dsp.exec_cmd(switchWs .. " 6"))
hl.bind("SUPER + 7", hl.dsp.exec_cmd(switchWs .. " 7"))
hl.bind("SUPER + 8", hl.dsp.exec_cmd(switchWs .. " 8"))
hl.bind("SUPER + 9", hl.dsp.exec_cmd(switchWs .. " 9"))
hl.bind("SUPER + 0", hl.dsp.exec_cmd(switchWs .. " 10"))

-- Move active window to a workspace with mainMod + SHIFT + [0-9]
hl.bind("SUPER + SHIFT + 1", hl.dsp.window.move({ workspace = "1" }))
hl.bind("SUPER + SHIFT + 2", hl.dsp.window.move({ workspace = "2" }))
hl.bind("SUPER + SHIFT + 3", hl.dsp.window.move({ workspace = "3" }))
hl.bind("SUPER + SHIFT + 4", hl.dsp.window.move({ workspace = "4" }))
hl.bind("SUPER + SHIFT + 5", hl.dsp.window.move({ workspace = "5" }))
hl.bind("SUPER + SHIFT + 6", hl.dsp.window.move({ workspace = "6" }))
hl.bind("SUPER + SHIFT + 7", hl.dsp.window.move({ workspace = "7" }))
hl.bind("SUPER + SHIFT + 8", hl.dsp.window.move({ workspace = "8" }))
hl.bind("SUPER + SHIFT + 9", hl.dsp.window.move({ workspace = "9" }))
hl.bind("SUPER + SHIFT + 0", hl.dsp.window.move({ workspace = "10" }))

-- Swap active window with the one next to it with mainMod + SHIFT + arrow keys
hl.bind("SUPER + SHIFT + h", hl.dsp.window.swap({ direction = "left" }))
hl.bind("SUPER + SHIFT + l", hl.dsp.window.swap({ direction = "right" }))
hl.bind("SUPER + SHIFT + k", hl.dsp.window.swap({ direction = "up" }))
hl.bind("SUPER + SHIFT + j", hl.dsp.window.swap({ direction = "down" }))

-- Resize active window
hl.bind("SUPER + minus", hl.dsp.window.resize({ x = -100, y = 0, relative = true }))
hl.bind("SUPER + equal", hl.dsp.window.resize({ x = 100, y = 0, relative = true }))
hl.bind("SUPER + SHIFT + minus", hl.dsp.window.resize({ x = 0, y = -100, relative = true }))
hl.bind("SUPER + SHIFT + equal", hl.dsp.window.resize({ x = 0, y = 100, relative = true }))

-- Focus the other monitor
hl.bind("SUPER + comma", hl.dsp.focus({ monitor = "l" }))
hl.bind("SUPER + period", hl.dsp.focus({ monitor = "r" }))

-- Move active window to the other monitor
hl.bind("SUPER + SHIFT + comma", hl.dsp.window.move({ monitor = "l" }))
hl.bind("SUPER + SHIFT + period", hl.dsp.window.move({ monitor = "r" }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind("SUPER + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind("SUPER + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Multimedia keys for volume
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true, repeating = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true, repeating = true })

-- Control Apple Display brightness (omarchy not installed -- needs replacement)
-- bind = CTRL, F1, exec, ~/.local/share/omarchy/bin/apple-display-brightness -5000
-- bind = CTRL, F2, exec, ~/.local/share/omarchy/bin/apple-display-brightness +5000
-- bind = SHIFT CTRL, F2, exec, ~/.local/share/omarchy/bin/apple-display-brightness +60000

-- Requires playerctl
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

-- Screenshots (grim + slurp) -- Mac-style: Shift+3/4/W/F
hl.bind("SUPER + SHIFT + S", hl.dsp.exec_cmd("~/.config/hypr/scripts/screenshot.sh region"))
hl.bind("SUPER + SHIFT + W", hl.dsp.exec_cmd("~/.config/hypr/scripts/screenshot.sh window"))
hl.bind("SUPER + SHIFT + F", hl.dsp.exec_cmd("~/.config/hypr/scripts/screenshot.sh output"))

-- Screen recording (wf-recorder) -- toggle region or full screen
-- SUPER+ALT+R        toggles region recording (select area with crosshair, press again to stop)
-- SUPER+ALT+SHIFT+R  toggles full-screen recording (press again to stop)
hl.bind("SUPER + ALT + R", hl.dsp.exec_cmd("~/.config/hypr/scripts/record.sh region"))
hl.bind("SUPER + ALT + SHIFT + R", hl.dsp.exec_cmd("~/.config/hypr/scripts/record.sh output"))

-- Color picker (hyprpicker not available on Fedora ARM64)
-- hl.bind("SUPER + SHIFT + C", hl.dsp.exec_cmd("hyprpicker -a"))

-- Clipse
hl.bind("CTRL + SUPER + V", hl.dsp.exec_cmd(terminal .. " --class clipse -e clipse"))
