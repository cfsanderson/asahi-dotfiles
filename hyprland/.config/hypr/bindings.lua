local apps = require("apps")

local mainMod = "SUPER"
local scripts = "~/.config/hypr/scripts/"

local function exec(keys, cmd, opts)
    hl.bind(keys, hl.dsp.exec_cmd(cmd), opts)
end

-- Keyboard backlight control
exec("XF86KbdBrightnessDown", "brightnessctl -d kbd_backlight set 5%-")
exec("XF86KbdBrightnessUp",   "brightnessctl -d kbd_backlight set 5%+")
exec("F3", "brightnessctl -d kbd_backlight set 5%-")
exec("F4", "brightnessctl -d kbd_backlight set 5%+")

-- Start default apps
exec(mainMod .. " + P",      apps.passwordManager)
exec(mainMod .. " + slash",  apps.passwordManager)
exec(mainMod .. " + return", apps.terminal)
exec(mainMod .. " + F",      apps.fileManager)
exec(mainMod .. " + B",      apps.browser)
exec(mainMod .. " + C",      apps.claude)
exec(mainMod .. " + M",      apps.mail)
exec(mainMod .. " + N",      apps.terminal .. " -e nvim")
exec(mainMod .. " + T",      apps.terminal .. " -e btop")
exec(mainMod .. " + D",      apps.terminal .. " -e lazydocker")
exec(mainMod .. " + G",      apps.messenger)
exec(mainMod .. " + S",      "signal-desktop")
exec(mainMod .. " + O",      "flatpak run md.obsidian.Obsidian")

exec(mainMod .. " + space",         scripts .. "launch-wofi.sh")
exec(mainMod .. " + SHIFT + SPACE", "pkill -SIGUSR1 waybar")

hl.bind(mainMod .. " + W", hl.dsp.window.close())

-- Go fullscreen
hl.bind("F11", hl.dsp.window.fullscreen())

-- End active session
exec(mainMod .. " + ESCAPE",                "hyprlock")
exec(mainMod .. " + SHIFT + ESCAPE",        "systemctl suspend")
hl.bind(mainMod .. " + ALT + ESCAPE",       hl.dsp.exit())
exec(mainMod .. " + CTRL + ESCAPE",         "reboot")
exec(mainMod .. " + SHIFT + CTRL + ESCAPE", "systemctl poweroff")

-- Control tiling
hl.bind(mainMod .. " + semicolon", hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + P",         hl.dsp.window.pseudo()) -- dwindle
hl.bind(mainMod .. " + V",         hl.dsp.window.float())

-- Move focus with mainMod + hjkl
hl.bind(mainMod .. " + h", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + l", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + k", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + j", hl.dsp.focus({ direction = "down" }))

-- Switch workspaces with mainMod + [0-9]
-- Uses handle-monitor.sh to focus the correct monitor first (1-5 laptop, 6-10 external)
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    exec(mainMod .. " + " .. key, scripts .. "handle-monitor.sh switch " .. i)
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Swap active window with the one next to it with mainMod + SHIFT + hjkl
hl.bind(mainMod .. " + SHIFT + h", hl.dsp.window.swap({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + l", hl.dsp.window.swap({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + k", hl.dsp.window.swap({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + j", hl.dsp.window.swap({ direction = "down" }))

-- Resize active window
hl.bind(mainMod .. " + minus",         hl.dsp.window.resize({ x = -100, y = 0,    relative = true }))
hl.bind(mainMod .. " + equal",         hl.dsp.window.resize({ x = 100,  y = 0,    relative = true }))
hl.bind(mainMod .. " + SHIFT + minus", hl.dsp.window.resize({ x = 0,    y = -100, relative = true }))
hl.bind(mainMod .. " + SHIFT + equal", hl.dsp.window.resize({ x = 0,    y = 100,  relative = true }))

-- Focus the other monitor
hl.bind(mainMod .. " + comma",  hl.dsp.focus({ monitor = "l" }))
hl.bind(mainMod .. " + period", hl.dsp.focus({ monitor = "r" }))

-- Move active window to the other monitor
hl.bind(mainMod .. " + SHIFT + comma",  hl.dsp.window.move({ monitor = "l" }))
hl.bind(mainMod .. " + SHIFT + period", hl.dsp.window.move({ monitor = "r" }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Laptop multimedia keys for volume and LCD brightness
local lockedRepeat = { locked = true, repeating = true }
exec("XF86AudioRaiseVolume",  "wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+", lockedRepeat)
exec("XF86AudioLowerVolume",  "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-",      lockedRepeat)
exec("XF86AudioMute",         "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle",     lockedRepeat)
exec("XF86AudioMicMute",      "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle",   lockedRepeat)
exec("XF86MonBrightnessUp",   "brightnessctl -e4 -n2 set 5%+",                  lockedRepeat)
exec("XF86MonBrightnessDown", "brightnessctl -e4 -n2 set 5%-",                  lockedRepeat)

-- Requires playerctl
exec("XF86AudioNext",  "playerctl next",        { locked = true })
exec("XF86AudioPause", "playerctl play-pause",  { locked = true })
exec("XF86AudioPlay",  "playerctl play-pause",  { locked = true })
exec("XF86AudioPrev",  "playerctl previous",    { locked = true })

-- Screenshots (grim + slurp) — Mac-style: Shift+S/W/F
exec(mainMod .. " + SHIFT + S", scripts .. "screenshot.sh region")
exec(mainMod .. " + SHIFT + W", scripts .. "screenshot.sh window")
exec(mainMod .. " + SHIFT + F", scripts .. "screenshot.sh output")

-- Screen recording (wf-recorder) — toggle region or full screen
-- SUPER+ALT+R        toggles region recording (select area with crosshair, press again to stop)
-- SUPER+ALT+SHIFT+R  toggles full-screen recording (press again to stop)
exec(mainMod .. " + ALT + R",         scripts .. "record.sh region")
exec(mainMod .. " + ALT + SHIFT + R", scripts .. "record.sh output")

-- Clipse
exec("CTRL + " .. mainMod .. " + V", apps.terminal .. " --class clipse -e clipse")
