-- https://wiki.hypr.land/Configuring/Basics/Variables/#input
hl.config({
    input = {
        kb_layout = "us",
        kb_variant = "",
        kb_model = "",
        kb_rules = "",

        follow_mouse = 1,

        sensitivity = 0.2,           -- -1.0 - 1.0, shifts the libinput acceleration curve (not raw speed); 0 = baseline, positive = accelerates sooner/higher, negative = delays/decelerates
        accel_profile = "adaptive",  -- flat = constant 1:1 speed regardless of movement speed (good for muscle memory); adaptive (default) = slow movements decelerate for precision, fast movements accelerate up to 3.5x
        natural_scroll = true,       -- Reverse scroll direction for mouse

        repeat_rate = 65,
        repeat_delay = 250,
        kb_options = "",

        touchpad = {
            natural_scroll = true,
            tap_to_click = true,
            disable_while_typing = true, -- prevent accidental touches
            clickfinger_behavior = true, -- 2-finger = right-click, 3-finger = middle
            scroll_factor = 0.7,         -- adjust if scroll feels too fast/slow
            tap_and_drag = true,         -- tap and hold to drag
            drag_lock = true,            -- keep dragging after briefly lifting finger
        },
    },
})

-- https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
