local wezterm = require('wezterm')

-- 获取当前插件目录并设置package.path
local is_windows = string.match(wezterm.target_triple, 'windows') ~= nil
local separator = is_windows and '\\' or '/'

local plugin_dir = wezterm.plugin.list()[1].plugin_dir
package.path = package.path
  .. ';'
  .. plugin_dir
  .. separator
  .. 'plugin'
  .. separator
  .. '?.lua'

local ime_switcher = require('ime_switcher')
local osc_handler = require('osc_handler')

local M = {}

local IME_STATE = {
  EN = "EN",
  IME = "IME"
}

function M.setup(opts)
  opts = opts or {}
  
  local config = {
    auto_switch = opts.auto_switch or true,
    log_level = opts.log_level or "info",
    ime_mapping = opts.ime_mapping or {},
  }

  wezterm.log_info("[WezTerm IME Helper] Plugin setup called")

  -- 注册用户变量变化事件
  wezterm.on('user-var-changed', function(window, pane, name, value)
    if name == 'wezterm_ime_control' or name == 'IME_CONTROL' then
      local state = (value or ""):upper()
      if state == IME_STATE.EN or state == IME_STATE.IME then
        ime_switcher.switch_input_method(state, config.ime_mapping)
        wezterm.log_info(string.format("[IME Helper] Switched input method to %s", state))
      else
        wezterm.log_error(string.format("[IME Helper] Invalid user variable value: %s", value))
      end
    end
  end)

  -- 注册OSC序列处理
  osc_handler.setup(config)

  return config
end

M.IME_STATE = IME_STATE

return M