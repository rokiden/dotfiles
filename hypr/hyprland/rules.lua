local colors = require("hyprland.catppuccin.themes.catppuccin-mocha")

-- Ignore maximize requests from all apps. You'll probably like this.
hl.window_rule({
    name           = "suppress-maximize-events",
    match          = { class = ".*" },
    suppress_event = "maximize",
})

-- Fix some dragging issues with XWayland
hl.window_rule({
    name     = "fix-xwayland-drags",
    match    = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },
    no_focus = true,
})

-- XWayland red border
hl.window_rule({ match = { xwayland = true }, border_size = 2, border_color = colors.red })

-- Fullscreen without borders
hl.workspace_rule({
    workspace = "f[1]",
    gaps_out = 0,
    gaps_in = 0,
    no_border = true,
    no_rounding = true,
})

-- Rofi
hl.layer_rule({ match = { namespace = "rofi" }, dim_around = true })
