---@module 'hl'

hl.config({
    general = {
        extend_border_grab_area = 30,
    },
    gestures = {
        workspace_swipe = true,
        workspace_swipe_cancel_ratio = 0.2,
    },
})

-- Single window maximize
hl.workspace_rule({
    workspace = "w[tv1]",
    gaps_out = 0,
    gaps_in = 0,
    no_border = true,
    no_rounding = true,
})
