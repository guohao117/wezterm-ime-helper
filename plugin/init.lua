local wezterm = require("wezterm")

-- 获取当前插件目录并设置package.path
local is_windows = string.match(wezterm.target_triple, "windows") ~= nil
local separator = is_windows and "\\" or "/"

local plugin_dir = wezterm.plugin.list()[1].plugin_dir
package.path = package.path .. ";" .. plugin_dir .. separator .. "plugin" .. separator .. "?.lua"

local ime_switcher = require("ime_switcher")

local M = {}

local IME_STATE = {
  EN = "EN",
  IME = "IME",
}

function M.setup(opts)
  opts = opts or {}

  local config = {
    auto_switch = opts.auto_switch or true,
    log_level = opts.log_level or "info",
    ime_mapping = opts.ime_mapping or {},
    enable_command_palette = opts.enable_command_palette ~= false, -- 默认启用
  }

  wezterm.log_info("[WezTerm IME Helper] Plugin setup called")

  -- 注册用户变量变化事件（用于远程/Neovim集成）
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

  -- 注册命令面板命令
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
    window:toast_notification(
      "WezTerm IME Helper",
      string.format("Toggled to %s input method", new_state),
      nil,
      1000
    )
    wezterm.log_info(
      string.format("[IME Helper] Toggled from %s to %s", current_state or "unknown", new_state)
    )
  end)

  -- 注册命令面板增强（如果启用）
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

-- 导出 IME 切换函数供用户直接调用
-- 返回完整的 wezterm.action 对象，可以直接用于 key binding
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
