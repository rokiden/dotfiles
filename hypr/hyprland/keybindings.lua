local commands = require("hyprland.commands")

local main_mod = "SUPER"
local floatRules = { float = true, size = { "(monitor_w*0.5)", "(monitor_h*0.5)" } }

hl.bind(main_mod.." + C",         hl.dsp.window.close()                                        )
hl.bind(main_mod.." + V",         hl.dsp.window.float()                                        )
hl.bind(main_mod.." + P",         hl.dsp.window.pseudo()                                       )
hl.bind(main_mod.." + J",         hl.dsp.layout("togglesplit")                                 )
hl.bind(main_mod.." + F",         hl.dsp.window.fullscreen({ mode = 1 })                       )
hl.bind(main_mod.." + SHIFT + F", hl.dsp.window.fullscreen({ mode = 0 })                       )
hl.bind(main_mod.." + ALT + F",   hl.dsp.window.fullscreen_state({ internal = 0, client = 2 }) )
hl.bind(main_mod.." + Q",         hl.dsp.exec_cmd(commands.terminal)                                )
hl.bind(main_mod.." + SHIFT + Q", hl.dsp.exec_cmd(commands.terminal, floatRules)                    )
hl.bind(main_mod.." + I",         hl.dsp.exec_cmd(commands.calculator, floatRules)                  )
hl.bind(main_mod.." + E",         hl.dsp.exec_cmd(commands.file_manager)                            )
hl.bind(main_mod.." + RETURN",    hl.dsp.exec_cmd(commands.runmenu)                                 )
hl.bind(main_mod.." + KP_ENTER",  hl.dsp.exec_cmd(commands.runmenu)                                 )
hl.bind(main_mod.." + H",         hl.dsp.exec_cmd(commands.config_edit)                             )
hl.bind(main_mod.." + L",         hl.dsp.exec_cmd(commands.lock)                                    )
hl.bind(main_mod.." + Y",         hl.dsp.exec_cmd(commands.colorpicker)                             )
hl.bind(main_mod.." + N",         hl.dsp.exec_cmd(commands.notifications)                           )
hl.bind(main_mod.." + K",         hl.dsp.exec_cmd(commands.clipboard)                               )

-- Screenshot
hl.bind("PRINT",                hl.dsp.exec_cmd(commands.screenshot_monitor) )
hl.bind(main_mod.." + PRINT", hl.dsp.exec_cmd(commands.screenshot_window)  )
hl.bind("SHIFT + PRINT",        hl.dsp.exec_cmd(commands.screenshot_region)  )

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
hl.bind(main_mod.." + SHIFT + w",     hl.dsp.window.move({ workspace = "emptym" }))

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
