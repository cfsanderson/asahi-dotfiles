-- Hyprland Lua config. Docs: https://wiki.hypr.land/Configuring/Start/
-- Each require() runs in its own scope, so an error in one module doesn't
-- stop the rest from loading.

require("monitors")
require("autostart")
require("bindings")
require("envs")
require("looknfeel")
require("input")
require("windows")
require("theme")
