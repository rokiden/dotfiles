---@module 'hl'
-- Environment-specific Autostart
hl.on("hyprland.start", function()
    hl.exec_cmd("solaar -w hide -b solaar")
    hl.exec_cmd("[workspace special:S silent] flatpak run com.slack.Slack")
    hl.exec_cmd("[workspace 1] firefox")
    hl.exec_cmd("[workspace 2 silent] smerge")
    hl.exec_cmd("[workspace 3 silent] code")
end)
