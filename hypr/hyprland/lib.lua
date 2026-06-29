local function get_hostname()
    local handle = io.popen("hostname")
    if not handle then return "unknown" end
    local result = handle:read("*a"):gsub("%s+", "")
    handle:close()
    return (result ~= "" and result) or "unknown"
end

local hostname = get_hostname()
local hostpath = "hyprland.hosts."..hostname

function require_host(module_name)
    local module_path = hostpath.."."..module_name
    local success, result = pcall(require, module_path)
    return success and result or nil
end
