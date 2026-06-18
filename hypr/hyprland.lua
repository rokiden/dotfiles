---@module 'hl'

------------------
---- MONITORS ----
------------------

require("monitors")

------------------
---- COMMANDS ----
------------------

local cmd_terminal = "alacritty"
local cmd_file_manager = "nautilus"
local cmd_runmenu = "rofi -show combi"
local cmd_calculator = "alacritty -e bash --login -c ipython"
local cmd_clipboard = "cliphist list| rofi -dmenu| cliphist decode| wl-copy"
local cmd_config_edit =
"alacritty -e bash -c \"find dotfiles -type f ! -path '*/venv/*' ! -path '*/.git/*' ! -name '*.swp' | cut -d '/' -f2- | rofi -dmenu | xargs -ori vim dotfiles/{}\""
local cmd_lock = "loginctl lock-session"
local cmd_colorpicker = "hyprpicker| wl-copy"
local cmd_notifications = "swaync-client -t -sw"

local cmd_screenshot_monitor = "hyprshot -m output"
local cmd_screenshot_window  = "hyprshot -m window"
local cmd_screenshot_region  = "hyprshot -m region"

-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function()
    hl.exec_cmd("waybar")
    hl.exec_cmd("swaync")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("systemctl --user start hyprpolkitagent")
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
    hl.exec_cmd("hyprsunset")
end)

require("autostart")

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

hl.env("HYPRSHOT_DIR", os.getenv("HOME").."/Pictures/Screenshots")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
hl.env("QT_SCALE_FACTOR", "1.25")

-----------------------
----- PERMISSIONS -----
-----------------------

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Permissions/
-- Please note permission changes here require a Hyprland restart and are not applied on-the-fly
-- for security reasons

-- hl.config({
--   ecosystem = {
--     enforce_permissions = true,
--   },
-- })

-- hl.permission("/usr/(bin|local/bin)/grim", "screencopy", "allow")
-- hl.permission("/usr/(lib|libexec|lib64)/xdg-desktop-portal-hyprland", "screencopy", "allow")
-- hl.permission("/usr/(bin|local/bin)/hyprpm", "plugin", "allow")

-----------------------
---- LOOK AND FEEL ----
-----------------------

-- Refer to https://wiki.hypr.land/Configuring/Basics/Variables/

local colors = require("catppuccin.themes.catppuccin-mocha")

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

---------------
---- INPUT ----
---------------

hl.config({
    input = {
        kb_layout = "us,ru",
        kb_options = "grp:win_space_toggle,numpad:mac",
        follow_mouse = 1,
        sensitivity = 0,
        touchpad = {
            natural_scroll = true,
        },
        numlock_by_default = true,
        scroll_factor = 1,
    },
})

---------------------
---- KEYBINDINGS ----
---------------------

local main_mod = "SUPER"
local floatRules = { float = true, size = { "(monitor_w*0.5)", "(monitor_h*0.5)" } }

hl.bind(main_mod.." + C",         hl.dsp.window.close()                                        )
hl.bind(main_mod.." + V",         hl.dsp.window.float()                                        )
hl.bind(main_mod.." + P",         hl.dsp.window.pseudo()                                       )
hl.bind(main_mod.." + J",         hl.dsp.layout("togglesplit")                                 )
hl.bind(main_mod.." + F",         hl.dsp.window.fullscreen({ mode = 1 })                       )
hl.bind(main_mod.." + SHIFT + F", hl.dsp.window.fullscreen({ mode = 0 })                       )
hl.bind(main_mod.." + ALT + F",   hl.dsp.window.fullscreen_state({ internal = 0, client = 2 }) )
hl.bind(main_mod.." + Q",         hl.dsp.exec_cmd(cmd_terminal)                                )
hl.bind(main_mod.." + SHIFT + Q", hl.dsp.exec_cmd(cmd_terminal, floatRules)                    )
hl.bind(main_mod.." + I",         hl.dsp.exec_cmd(cmd_calculator, floatRules)                  )
hl.bind(main_mod.." + E",         hl.dsp.exec_cmd(cmd_file_manager)                            )
hl.bind(main_mod.." + RETURN",    hl.dsp.exec_cmd(cmd_runmenu)                                 )
hl.bind(main_mod.." + KP_ENTER",  hl.dsp.exec_cmd(cmd_runmenu)                                 )
hl.bind(main_mod.." + H",         hl.dsp.exec_cmd(cmd_config_edit)                             )
hl.bind(main_mod.." + L",         hl.dsp.exec_cmd(cmd_lock)                                    )
hl.bind(main_mod.." + Y",         hl.dsp.exec_cmd(cmd_colorpicker)                             )
hl.bind(main_mod.." + N",         hl.dsp.exec_cmd(cmd_notifications)                           )
hl.bind(main_mod.." + K",         hl.dsp.exec_cmd(cmd_clipboard)                               )

-- Screenshot
hl.bind("PRINT",                hl.dsp.exec_cmd(cmd_screenshot_monitor) )
hl.bind(main_mod.." + PRINT", hl.dsp.exec_cmd(cmd_screenshot_window)  )
hl.bind("SHIFT + PRINT",        hl.dsp.exec_cmd(cmd_screenshot_region)  )

-- Move focus with mainMod + arrow keys
hl.bind(main_mod.." + left", hl.dsp.focus({ direction = "left" }))
hl.bind(main_mod.." + right",hl.dsp.focus({ direction = "right" }))
hl.bind(main_mod.." + up",   hl.dsp.focus({ direction = "up" }))
hl.bind(main_mod.." + down", hl.dsp.focus({ direction = "down" }))

-- Swap window with mainMod + SHIFT + arrow keys
hl.bind(main_mod.." + SHIFT + left", hl.dsp.window.swap({ direction = "left" }))
hl.bind(main_mod.." + SHIFT + right",hl.dsp.window.swap({ direction = "right" }))
hl.bind(main_mod.." + SHIFT + up",   hl.dsp.window.swap({ direction = "up" }))
hl.bind(main_mod.." + SHIFT + down", hl.dsp.window.swap({ direction = "down" }))

-- Moves workspace to monitor with mainMod + ALT + arrow keys
hl.bind(main_mod.." + ALT + left",  hl.dsp.workspace.move({ monitor = "l" }))
hl.bind(main_mod.." + ALT + right", hl.dsp.workspace.move({ monitor = "r" }))
hl.bind(main_mod.." + ALT + up",    hl.dsp.workspace.move({ monitor = "u" }))
hl.bind(main_mod.." + ALT + down",  hl.dsp.workspace.move({ monitor = "d" }))

-- Moves workspace to next monitor with mainMod + ALT + TAB
hl.bind(main_mod.." + ALT + TAB", hl.dsp.workspace.move({ monitor = "+1" }))

-- Switch workspaces with mainMod + [0-9]
hl.bind(main_mod.." + 1", hl.dsp.focus({ workspace = 1 }))
hl.bind(main_mod.." + 2", hl.dsp.focus({ workspace = 2 }))
hl.bind(main_mod.." + 3", hl.dsp.focus({ workspace = 3 }))
hl.bind(main_mod.." + 4", hl.dsp.focus({ workspace = 4 }))
hl.bind(main_mod.." + 5", hl.dsp.focus({ workspace = 5 }))
hl.bind(main_mod.." + 6", hl.dsp.focus({ workspace = 6 }))
hl.bind(main_mod.." + 7", hl.dsp.focus({ workspace = 7 }))
hl.bind(main_mod.." + 8", hl.dsp.focus({ workspace = 8 }))
hl.bind(main_mod.." + 9", hl.dsp.focus({ workspace = 9 }))
hl.bind(main_mod.." + 0", hl.dsp.focus({ workspace = 10 }))

-- Switch workspaces with mainMod + Num[0-9]
hl.bind(main_mod.." + code:87",     hl.dsp.focus({ workspace = 1 }))
hl.bind(main_mod.." + code:88",     hl.dsp.focus({ workspace = 2 }))
hl.bind(main_mod.." + code:89",     hl.dsp.focus({ workspace = 3 }))
hl.bind(main_mod.." + code:83",     hl.dsp.focus({ workspace = 4 }))
hl.bind(main_mod.." + code:84",     hl.dsp.focus({ workspace = 5 }))
hl.bind(main_mod.." + code:85",     hl.dsp.focus({ workspace = 6 }))
hl.bind(main_mod.." + code:79",     hl.dsp.focus({ workspace = 7 }))
hl.bind(main_mod.." + code:80",     hl.dsp.focus({ workspace = 8 }))
hl.bind(main_mod.." + code:81",     hl.dsp.focus({ workspace = 9 }))
hl.bind(main_mod.." + code:90",     hl.dsp.focus({ workspace = 10 }))
hl.bind(main_mod.." + grave",       hl.dsp.focus({ workspace = "previous" }))
hl.bind(main_mod.." + TAB",         hl.dsp.focus({ workspace = "m+1" }))
hl.bind(main_mod.." + SHIFT + TAB", hl.dsp.focus({ workspace = "m-1" }))
hl.bind(main_mod.." + w",           hl.dsp.focus({ workspace = "emptym" }))

-- Move active window to a workspace with mainMod + SHIFT + [0-9]
hl.bind(main_mod.." + SHIFT + 1",     hl.dsp.window.move({ workspace = 1 }))
hl.bind(main_mod.." + SHIFT + 2",     hl.dsp.window.move({ workspace = 2 }))
hl.bind(main_mod.." + SHIFT + 3",     hl.dsp.window.move({ workspace = 3 }))
hl.bind(main_mod.." + SHIFT + 4",     hl.dsp.window.move({ workspace = 4 }))
hl.bind(main_mod.." + SHIFT + 5",     hl.dsp.window.move({ workspace = 5 }))
hl.bind(main_mod.." + SHIFT + 6",     hl.dsp.window.move({ workspace = 6 }))
hl.bind(main_mod.." + SHIFT + 7",     hl.dsp.window.move({ workspace = 7 }))
hl.bind(main_mod.." + SHIFT + 8",     hl.dsp.window.move({ workspace = 8 }))
hl.bind(main_mod.." + SHIFT + 9",     hl.dsp.window.move({ workspace = 9 }))
hl.bind(main_mod.." + SHIFT + 0",     hl.dsp.window.move({ workspace = 10 }))
hl.bind(main_mod.." + SHIFT + grave", hl.dsp.window.move({ workspace = "previous" }))

-- Move active window to a workspace with mainMod + SHIFT + Num[0-9]
hl.bind(main_mod.." + SHIFT + code:87", hl.dsp.window.move({ workspace = 1 }))
hl.bind(main_mod.." + SHIFT + code:88", hl.dsp.window.move({ workspace = 2 }))
hl.bind(main_mod.." + SHIFT + code:89", hl.dsp.window.move({ workspace = 3 }))
hl.bind(main_mod.." + SHIFT + code:83", hl.dsp.window.move({ workspace = 4 }))
hl.bind(main_mod.." + SHIFT + code:84", hl.dsp.window.move({ workspace = 5 }))
hl.bind(main_mod.." + SHIFT + code:85", hl.dsp.window.move({ workspace = 6 }))
hl.bind(main_mod.." + SHIFT + code:79", hl.dsp.window.move({ workspace = 7 }))
hl.bind(main_mod.." + SHIFT + code:80", hl.dsp.window.move({ workspace = 8 }))
hl.bind(main_mod.." + SHIFT + code:81", hl.dsp.window.move({ workspace = 9 }))
hl.bind(main_mod.." + SHIFT + code:90", hl.dsp.window.move({ workspace = 10 }))

-- Special workspace
hl.bind(main_mod.." + S",         hl.dsp.workspace.toggle_special("S"))
hl.bind(main_mod.." + SHIFT + S", hl.dsp.window.move({ workspace = "special:S" }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(main_mod.." + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(main_mod.." + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Move windows with mainMod + LMB and dragging
hl.bind(main_mod.." + mouse:272", hl.dsp.window.drag(), { mouse = true })

-- Resize windows with mainMod + SHIFT + LMB and dragging
hl.bind(main_mod.." + SHIFT + mouse:272", hl.dsp.window.resize(), { mouse = true })

-- Groups
hl.bind("ALT + TAB", hl.dsp.group.next())
hl.bind("ALT + SHIFT + TAB", hl.dsp.group.next({ forward = false }))
hl.bind(main_mod.." + G", hl.dsp.group.toggle())
hl.bind(main_mod.." + ALT + G", hl.dsp.group.lock_active("toggle"))
hl.bind(main_mod.." + SHIFT + G", hl.dsp.submap("GROUP"))
hl.define_submap("GROUP", function()
    hl.bind("left",   hl.dsp.window.move({ into_group = "l" }))
    hl.bind("right",  hl.dsp.window.move({ into_group = "r" }))
    hl.bind("up",     hl.dsp.window.move({ into_group = "u" }))
    hl.bind("down",   hl.dsp.window.move({ into_group = "d" }))
    hl.bind("left",   hl.dsp.submap("reset"))
    hl.bind("right",  hl.dsp.submap("reset"))
    hl.bind("up",     hl.dsp.submap("reset"))
    hl.bind("down",   hl.dsp.submap("reset"))
    hl.bind("escape", hl.dsp.submap("reset"))
end)

-- Multimedia keys for volume and LCD brightness
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl s 5%+"), { locked = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s 5%-"), { locked = true })

-- Requires playerctl
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

-------------------------------------
---- WINDOWS, WORKSPACES, LAYERS ----
-------------------------------------

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
