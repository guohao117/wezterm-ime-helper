local wezterm = require("wezterm")

local M = {}

-- OS detection utilities
M.os = {}

function M.os.detect_os()
  local target = wezterm.target_triple
  if target:find("darwin") then
    return "macOS"
  elseif target:find("windows") then
    return "Windows"
  elseif target:find("linux") then
    return "Linux"
  else
    return "Unknown"
  end
end

return M
