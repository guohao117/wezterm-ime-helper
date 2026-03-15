local wezterm = require("wezterm")

-- 合并 plugin 下的所有模块到单个文件，避免处理 package.path

-- utils (原 utils.lua)
local utils = {}
utils.os = {}
function utils.os.detect_os()
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

-- ime_switcher (原 ime_switcher.lua)
local ime_switcher = {}

local DEFAULT_IME_MAPPING = {
  macOS = {
    EN = "com.apple.keylayout.ABC",
    IME = "com.apple.inputmethod.SCIM.ITABC",
  },
  Windows = {
    EN = "1033",
    IME = "2052",
  },
  Linux = {
    EN = "xkb:us::eng",
    IME = "pinyin",
  },
}

function ime_switcher.switch_input_method(state, user_mapping)
  local os_name = utils.os.detect_os()
  local mapping = (user_mapping or {})[os_name] or DEFAULT_IME_MAPPING[os_name]

  if not mapping then
    wezterm.log_error(string.format("[IME Switcher] Unsupported OS: %s", os_name))
    return false
  end

  local ime_id = mapping[state]
  if not ime_id then
    wezterm.log_error(string.format("[IME Switcher] No mapping for state %s on %s", state, os_name))
    return false
  end

  local current_state = ime_switcher.get_current_ime_state()
  if current_state == state then
    wezterm.log_info(string.format("[IME Switcher] Already in %s state, skipping switch", state))
    return true
  end

  if os_name == "macOS" then
    local cmd = string.format('/usr/local/bin/macism "%s"', ime_id)
    local success, stdout, stderr = wezterm.run_child_process({ "sh", "-c", cmd })
    if not success then
      wezterm.log_error(string.format("[IME Switcher] macOS switch failed: %s", stderr))
      return false
    end
  elseif os_name == "Windows" then
    local cmd = string.format("im-select.exe %s", ime_id)
    local success, stdout, stderr = wezterm.run_child_process({ "cmd", "/c", cmd })
    if not success then
      wezterm.log_error(string.format("[IME Switcher] Windows switch failed: %s", stderr))
      return false
    end
  elseif os_name == "Linux" then
    local cmd = string.format("ibus engine %s", ime_id)
    local success, stdout, stderr = wezterm.run_child_process({ "sh", "-c", cmd })
    if not success then
      cmd = string.format("fcitx-remote -s %s", ime_id)
      success, stdout, stderr = wezterm.run_child_process({ "sh", "-c", cmd })
      if not success then
        wezterm.log_error(string.format("[IME Switcher] Linux switch failed: %s", stderr))
        return false
      end
    end
  end

  wezterm.log_info(string.format("[IME Switcher] Successfully switched to %s (%s) on %s", state, ime_id, os_name))
  return true
end

function ime_switcher.get_current_ime_state()
  local os_name = utils.os.detect_os()

  if os_name == "macOS" then
    local success, stdout, stderr = wezterm.run_child_process({ "sh", "-c", "/usr/local/bin/macism" })
    if success and stdout then
      local current_ime = stdout:gsub("%s+", "")
      if current_ime:find("com.apple.keylayout") then
        return "EN"
      else
        return "IME"
      end
    end
  elseif os_name == "Windows" then
    local success, stdout, stderr = wezterm.run_child_process({ "cmd", "/c", "im-select.exe" })
    if success and stdout then
      local current_ime = stdout:gsub("%s+", "")
      local current_ime_num = tonumber(current_ime)
      if current_ime_num == 1033 or current_ime_num == 2057 or current_ime_num == 3081 then
        return "EN"
      else
        return "IME"
      end
    end
  elseif os_name == "Linux" then
    local success, stdout, stderr = wezterm.run_child_process({ "sh", "-c", "ibus engine" })
    if success and stdout then
      local current_ime = stdout:gsub("%s+", "")
      if current_ime:find("xkb:us") or current_ime:find("eng") then
        return "EN"
      else
        return "IME"
      end
    else
      success, stdout, stderr = wezterm.run_child_process({ "sh", "-c", "fcitx-remote -n" })
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

  return nil
end

-- 主插件逻辑（合并后的 init）
local M = {}

local IME_STATE = { EN = "EN", IME = "IME" }

function M.setup(opts)
  opts = opts or {}

  local config = {
    auto_switch = opts.auto_switch or true,
    log_level = opts.log_level or "info",
    ime_mapping = opts.ime_mapping or {},
    enable_command_palette = opts.enable_command_palette ~= false,
  }

  wezterm.log_info("[WezTerm IME Helper] Plugin setup called")

  wezterm.on("user-var-changed", function(window, pane, name, value)
    if name == "wezterm_ime_control" or name == "IME_CONTROL" then
      local state = (value or ""):upper()
      if state == IME_STATE.EN then
        wezterm.emit("ime-helper-switch-to-en", window, pane)
      elseif state == IME_STATE.IME then
        wezterm.emit("ime-helper-switch-to-ime", window, pane)
      else
        wezterm.log_error(string.format("[IME Helper] Invalid user variable value: %s", value))
      end
    end
  end)

  wezterm.on("ime-helper-switch-to-en", function(window, pane)
    ime_switcher.switch_input_method(IME_STATE.EN, config.ime_mapping)
    window:toast_notification("WezTerm IME Helper", "Switched to English input method", nil, 1000)
    wezterm.log_info("[IME Helper] Switched to English input method")
  end)

  wezterm.on("ime-helper-switch-to-ime", function(window, pane)
    ime_switcher.switch_input_method(IME_STATE.IME, config.ime_mapping)
    window:toast_notification("WezTerm IME Helper", "Switched to IME input method", nil, 1000)
    wezterm.log_info("[IME Helper] Switched to IME input method")
  end)

  wezterm.on("ime-helper-toggle", function(window, pane)
    local current_state = ime_switcher.get_current_ime_state()
    local new_state = (current_state == IME_STATE.EN) and IME_STATE.IME or IME_STATE.EN
    ime_switcher.switch_input_method(new_state, config.ime_mapping)
    window:toast_notification("WezTerm IME Helper", string.format("Toggled to %s input method", new_state), nil, 1000)
    wezterm.log_info(string.format("[IME Helper] Toggled from %s to %s", current_state or "unknown", new_state))
  end)

  if config.enable_command_palette then
    wezterm.on("augment-command-palette", function(window, pane)
      return {
        {
          brief = "Switch to English IME",
          icon = "md_keyboard",
          action = wezterm.action.EmitEvent("ime-helper-switch-to-en"),
        },
        {
          brief = "Switch to IME",
          icon = "md_translate",
          action = wezterm.action.EmitEvent("ime-helper-switch-to-ime"),
        },
        {
          brief = "Toggle IME",
          icon = "md_swap_horiz",
          action = wezterm.action.EmitEvent("ime-helper-toggle"),
        },
      }
    end)
  end

  wezterm.log_info("[WezTerm IME Helper] Plugin setup completed")
end

function M.switch_to_en()
  return wezterm.action.EmitEvent("ime-helper-switch-to-en")
end

function M.switch_to_ime()
  return wezterm.action.EmitEvent("ime-helper-switch-to-ime")
end

function M.toggle()
  return wezterm.action.EmitEvent("ime-helper-toggle")
end

M.IME_STATE = IME_STATE

return M
