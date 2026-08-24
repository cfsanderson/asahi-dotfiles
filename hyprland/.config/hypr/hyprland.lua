-- Migrated from hyprland.conf (hyprlang) to Lua, 2026-08-22.
-- hyprlang / .conf support is dropped in Hyprland 0.57; this is the
-- replacement config format. See https://wiki.hypr.land/Configuring/

-- Default applications (globals, so the required files below can see them)
terminal        = "kitty"
fileManager     = "nautilus --new-window"
browser         = "brave-browser --new-window"
passwordManager = "1password"
messenger       = "signal-desktop"
webapp          = "zen-browser --new-window"
mail            = "zen-browser --new-window https://mail.proton.me/u/0/inbox"
claude          = "claude-desktop"

-- My configs
require("monitors")
require("autostart")
require("bindings")
require("envs")
require("looknfeel")
require("input")
require("windows")
require("theme")
