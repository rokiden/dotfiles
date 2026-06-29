
-- Refer to https://wiki.hypr.land/Configuring/Basics/Variables/

local colors = require("hyprland.catppuccin.themes.catppuccin-mocha")

local c_inactive = "rgba(4D5068a0)"

hl.config({
    general = {
        col = {
            active_border = colors.sapphire,
            inactive_border = c_inactive,
        },
    },
    group = {
        col = {
            border_active = colors.green,
            border_locked_active = colors.yellow,
            border_inactive = c_inactive,
            border_locked_inactive = c_inactive,
        },
        groupbar = {
            col = {
                active = "rgba(577954a0)",
                locked_active = "rgba(86795ca0)",
                inactive = c_inactive,
                locked_inactive = c_inactive,
            },
        },
    },
})

hl.window_rule({ match = { workspace = "s[1]" }, border_color = "rgba("..colors.mauveAlpha.."a0)" })

hl.config({
    general = {
        gaps_in = 4,
        gaps_out = 8,
        border_size = 1,
        resize_on_border = true,
        allow_tearing = false,
        layout = "dwindle",
    },
})
-- special workspace with big gaps
hl.workspace_rule({
    workspace = "s[1]",
    gaps_out = 32,
    gaps_in = 16,
    border_size = 2,
})

hl.config({
    group = {
        drag_into_group = 2,
        merge_groups_on_drag = false,
        groupbar = {
            scrolling = false,
            height = 24,
            font_size = 16,
            text_offset = 1,
            indicator_height = 0,
            gradients = true,
            gradient_rounding = 8,
            gradient_round_only_edges = false,
            gaps_in = 6,
            gaps_out = 4,
        },
    },
    decoration = {
        rounding = 10,
        -- Change transparency of focused and unfocused windows
        active_opacity = 1.0,
        inactive_opacity = 1.0,
        dim_special = 0.5,
        dim_around = 0.3,
        shadow = { enabled = false },
        blur = { enabled = false },
    },
    animations = {
        enabled = true
    }
})
hl.animation({ leaf = "global", enabled = true, speed = 4, bezier = "default" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 4, bezier = "default", style = "fade" })
hl.animation({ leaf = "border", enabled = false })
hl.animation({ leaf = "borderangle", enabled = false })

hl.config({
    dwindle = {
        preserve_split = true,
    },
    misc = {
        force_default_wallpaper = 1,
        disable_hyprland_logo = false,
    },
    cursor = {
        warp_on_change_workspace = 1,
    },
    binds = {
        hide_special_on_workspace_change = true,
    },
})
