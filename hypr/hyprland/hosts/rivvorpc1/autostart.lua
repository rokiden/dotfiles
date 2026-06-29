---@module 'hl'

local monitors = require_host("monitors")

local timer_config = {timeout = 200, type = "oneshot"}

hl.on("hyprland.start", function()
  hl.timer(function()
    hl.dsp.workspace.move({ workspace = "1", monitor = monitors.left })
    hl.dsp.workspace.move({ workspace = "2", monitor = monitors.center })
    hl.dsp.workspace.move({ workspace = "3", monitor = monitors.right })

    hl.exec_cmd("solaar -w hide -b solaar")
    hl.exec_cmd("smerge", { workspace = "1" })
    hl.exec_cmd("code", { workspace = "2" })
    hl.exec_cmd("firefox", { workspace = "3" })
    hl.exec_cmd("flatpak run com.slack.Slack", { workspace = "special:S silent" })
  end, timer_config)
end)
