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
    EN = "1033", -- English US (0x0409)
    IME = "2052"  -- Chinese Simplified (0x0804)
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

  -- 检查当前状态，如果已经是期望的状态则跳过切换
  local current_state = M.get_current_ime_state()
  if current_state == state then
    wezterm.log_info(string.format("[IME Switcher] Already in %s state, skipping switch", state))
    return true
  end

  if os_name == "macOS" then
    local cmd = string.format('macism "%s"', ime_id)
    local success, stdout, stderr = wezterm.run_child_process({"sh", "-c", cmd})
    if not success then
      wezterm.log_error(string.format("[IME Switcher] macOS switch failed: %s", stderr))
      return false
    end
  elseif os_name == "Windows" then
    local cmd = string.format('im-select.exe %s', ime_id)
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
  elseif os_name == "Windows" then
    local success, stdout, stderr = wezterm.run_child_process({"cmd", "/c", "im-select.exe"})
    if success and stdout then
      local current_ime = stdout:gsub("%s+", "")
      local current_ime_num = tonumber(current_ime)
      -- 检查是否为英文输入法 (1033 = English US)
      -- 可以扩展支持更多英文输入法: 1033, 2057 (English UK), 3081 (English AU), etc.
      if current_ime_num == 1033 or current_ime_num == 2057 or current_ime_num == 3081 then
        return "EN"
      else
        return "IME"
      end
    end
  elseif os_name == "Linux" then
    -- 首先尝试 IBus
    local success, stdout, stderr = wezterm.run_child_process({"sh", "-c", "ibus engine"})
    if success and stdout then
      local current_ime = stdout:gsub("%s+", "")
      if current_ime:find("xkb:us") or current_ime:find("eng") then
        return "EN"
      else
        return "IME"
      end
    else
      -- 如果 IBus 失败，尝试 Fcitx
      success, stdout, stderr = wezterm.run_child_process({"sh", "-c", "fcitx-remote -n"})
      if success and stdout then
        local current_ime = stdout:gsub("%s+", "")
        if current_ime:find("xkb:us") or current_ime:find("eng") or current_ime == "keyboard-us" then
          return "EN"
        else
          return "IME"
        end
      end
    end
  end
  
  return nil -- 无法检测
end

return M