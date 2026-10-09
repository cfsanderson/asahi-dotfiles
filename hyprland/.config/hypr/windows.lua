-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/ for more
hl.window_rule({ match = { class = ".*" }, suppress_event = "maximize" })

-- Force chromium into a tile to deal with --app bug
hl.window_rule({ match = { class = "^(Chromium)$" }, tile = true })

-- Float sound and bluetooth settings
hl.window_rule({ match = { class = "^(org.pulseaudio.pavucontrol|blueberry.py)$" }, float = true })

-- Float Steam, fullscreen RetroArch
hl.window_rule({ match = { class = "^(steam)$" }, float = true })
hl.window_rule({ match = { class = "^(com.libretro.RetroArch)$" }, fullscreen = true })

-- Prevent Signal from opening fullscreen
hl.window_rule({ match = { class = "^(signal)$" }, tile = true })

hl.window_rule({ match = { class = ".*" }, opacity = "1 1" })
hl.window_rule({ match = { title = "^(youtube.com_/)$" }, opacity = "1 1" })
hl.window_rule({ match = { class = "^(zoom|vlc|org.kde.kdenlive|com.obsproject.Studio|com.github.PintaProject.Pinta)$" }, opacity = "1 1" })
hl.window_rule({ match = { class = "^(com.libretro.RetroArch|steam)$" }, opacity = "1 1" })

-- Fix some dragging issues with XWayland
hl.window_rule({
    name  = "fix-xwayland-drags",
    match = { class = "^$", title = "^$", xwayland = true, float = true, fullscreen = false, pin = false },
    no_focus = true,
})

-- Proper background blur for wofi
hl.layer_rule({ match = { namespace = "wofi" }, blur = true, ignore_alpha = 1 })

-- Float in the middle for clipse clipboard manager
hl.window_rule({
    match = { class = "clipse" },
    float = true,
    size  = { 622, 652 },
    stay_focused = true,
})
