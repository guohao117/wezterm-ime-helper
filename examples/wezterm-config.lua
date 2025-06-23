-- Example WezTerm configuration with IME Helper plugin
local wezterm = require('wezterm')
local ime_helper = wezterm.plugin.require('https://github.com/guohaodev/wezterm-ime-helper')

local config = wezterm.config_builder()

-- Setup IME helper (no return value)
ime_helper.setup({
  auto_switch = true,
  log_level = "info",
  enable_command_palette = true, -- 启用命令面板集成（默认）
  ime_mapping = {
    macOS = {
      EN = "com.apple.keylayout.ABC",
      IME = "com.apple.inputmethod.SCIM.ITABC"  -- or your preferred Chinese IME
    },
    Windows = {
      EN = "1033",  -- English (US)
      IME = "2052"  -- Chinese (Simplified)
    },
    Linux = {
      EN = "xkb:us::eng",
      IME = "pinyin"  -- or your preferred IME engine
    }
  }
})

-- Optional: Add key bindings for direct IME switching
config.keys = config.keys or {}

-- Add IME switching key bindings
table.insert(config.keys, {
  key = 'e',
  mods = 'CTRL|ALT',
  action = ime_helper.switch_to_en()
})

table.insert(config.keys, {
  key = 'i',
  mods = 'CTRL|ALT', 
  action = ime_helper.switch_to_ime()
})

table.insert(config.keys, {
  key = 't',
  mods = 'CTRL|ALT',
  action = ime_helper.toggle()
})

-- Other WezTerm configuration...
config.color_scheme = 'Tokyo Night'
config.font = wezterm.font('JetBrains Mono')
config.font_size = 14

return config
