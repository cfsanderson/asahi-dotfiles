-- Cursor size
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-- Force all apps to use Wayland
hl.env("GDK_BACKEND", "wayland")
hl.env("QT_QPA_PLATFORM", "wayland")
hl.env("QT_STYLE_OVERRIDE", "kvantum")
hl.env("SDL_VIDEODRIVER", "wayland")
hl.env("MOZ_ENABLE_WAYLAND", "1")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "wayland")
hl.env("OZONE_PLATFORM", "wayland")

hl.config({
    xwayland = {
        force_zero_scaling = true,
    },
})

-- Make Chromium use XCompose and all Wayland
hl.env("CHROMIUM_FLAGS", "--enable-features=UseOzonePlatform --ozone-platform=wayland --gtk-version=4")

-- Make .desktop files available for wofi (incl. Flatpak app entries)
hl.env("XDG_DATA_DIRS", "/home/caleb/.local/share/flatpak/exports/share:/var/lib/flatpak/exports/share:/home/caleb/.local/share:/usr/local/share:/usr/share")

-- Use XCompose file
hl.env("XCOMPOSEFILE", "~/.XCompose")

-- ecosystem block - not recognized by sdegler COPR build of Hyprland 0.53.3
-- (COPR excludes Qt GUI helpers / ecosystem module)
-- hl.config({ ecosystem = { no_update_news = true } })

-- Extra env variables (GDK_SCALE=1 since Hyprland handles scaling at 1.5x)
hl.env("GDK_SCALE", "1")

-- GNOME Keyring - allows Electron apps (Cursor, VS Code, etc.) to store secrets
hl.env("GNOME_KEYRING_CONTROL", "/run/user/1000/keyring")
