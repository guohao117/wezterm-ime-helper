local wezterm = require('wezterm')
local utils = require('utils')

local M = {}

-- 默认IME映射配置
local DEFAULT_IME_MAPPING = {
  macOS = {
    EN = "com.apple.keylayout.ABC",
    IME = "com.apple.inputmethod.SCIM.ITABC"
  },
  Windows = {
    EN = "0x0409", -- English US
    IME = "0x0804"  -- Chinese Simplified
  },
  Linux = {
    EN = "xkb:us::eng",
    IME = "pinyin"
  }
}

-- 跨平台输入法切换
function M.switch_input_method(state, user_mapping)
  local os_name = utils.os.detect_os()
  local mapping = user_mapping[os_name] or DEFAULT_IME_MAPPING[os_name]
  
  if not mapping then
    wezterm.log_error(string.format("[IME Switcher] Unsupported OS: %s", os_name))
    return false
  end

  local ime_id = mapping[state]
  if not ime_id then
    wezterm.log_error(string.format("[IME Switcher] No mapping for state %s on %s", state, os_name))
    return false
  end

  if os_name == "macOS" then
    local cmd = string.format('macism "%s"', ime_id)
    local success, stdout, stderr = wezterm.run_child_process({"sh", "-c", cmd})
    if not success then
      wezterm.log_error(string.format("[IME Switcher] macOS switch failed: %s", stderr))
      return false
    end
  elseif os_name == "Windows" then
    local cmd = string.format('powershell -Command "Set-WinUserLanguageList -LanguageList %s -Force"', ime_id)
    local success, stdout, stderr = wezterm.run_child_process({"cmd", "/c", cmd})
    if not success then
      wezterm.log_error(string.format("[IME Switcher] Windows switch failed: %s", stderr))
      return false
    end
  elseif os_name == "Linux" then
    local cmd = string.format('ibus engine %s', ime_id)
    local success, stdout, stderr = wezterm.run_child_process({"sh", "-c", cmd})
    if not success then
      cmd = string.format('fcitx-remote -s %s', ime_id)
      success, stdout, stderr = wezterm.run_child_process({"sh", "-c", cmd})
      if not success then
        wezterm.log_error(string.format("[IME Switcher] Linux switch failed: %s", stderr))
        return false
      end
    end
  end

  wezterm.log_info(string.format("[IME Switcher] Successfully switched to %s (%s) on %s", state, ime_id, os_name))
  return true
end

-- 获取当前IME状态（如果支持）
function M.get_current_ime_state()
  local os_name = utils.os.detect_os()
  
  if os_name == "macOS" then
    local success, stdout, stderr = wezterm.run_child_process({"macism"})
    if success and stdout then
      local current_ime = stdout:gsub("%s+", "")
      if current_ime:find("com.apple.keylayout") then
        return "EN"
      else
        return "IME"
      end
    end
  end
  
  return nil -- 无法检测
end

return M