---@module 'hl'

local monleft = "DP-2"
local moncenter = "DP-1"
local monright = "HDMI-A-1"

local disable_side_monitors = false

hl.monitor({
    output   = moncenter,
    mode     = "highres",
    position = "0x0",
    scale    = 1,
})

if disable_side_monitors then
    hl.monitor({ output = monleft, disabled = true })
    hl.monitor({ output = monright, disabled = true })
else
    hl.monitor({
        output   = monleft,
        mode     = "highres",
        position = "auto-left",
        scale    = 1,
    })

    hl.monitor({
        output   = monright,
        mode     = "highres",
        position = "auto-right",
        scale    = 1,
    })
end

return {
    left   = monleft,
    center = moncenter,
    right  = monright,
}
