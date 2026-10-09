-- Asahi Linux MacBook display
-- Run `hyprctl monitors` to see available monitors when in Hyprland
-- Dell U2720QM 4K via HDMI (plug in after boot)

-- --- SIDE BY SIDE (external right, bottom-edge aligned) ---
-- Logical sizes: external=2560x1440, laptop=1512x945
-- Laptop offset down by 495px (1440 - 945) to align bottom edges
-- hl.monitor({ output = "eDP-1",    mode = "3024x1890@120", position = "0x495",   scale = 2 })
-- hl.monitor({ output = "HDMI-A-1", mode = "3840x2160@60",  position = "1512x0",  scale = 1.5 })

-- --- STACKED (external on top, laptop centered below) ---
-- Logical sizes: external=2560x1440, laptop=1512x945
-- Laptop centered: (2560 - 1512) / 2 = 524px horizontal offset
hl.monitor({ output = "HDMI-A-1", mode = "3840x2160@60",  position = "0x0",      scale = 1.5 })
hl.monitor({ output = "eDP-1",    mode = "3024x1890@120", position = "524x1440", scale = 2 })
