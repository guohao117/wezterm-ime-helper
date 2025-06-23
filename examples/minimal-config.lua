-- Example: Minimal configuration without command palette
local wezterm = require('wezterm')
local ime_helper = wezterm.plugin.require('https://github.com/guohaodev/wezterm-ime-helper')

local config = wezterm.config_builder()

-- Setup IME helper with minimal configuration
ime_helper.setup({
  enable_command_palette = false, -- 禁用命令面板集成
  ime_mapping = {
    macOS = {
      EN = "com.apple.keylayout.ABC",
      IME = "com.apple.inputmethod.SCIM.ITABC"
    }
  }
})

-- Only use key bindings for IME switching
config.keys = {
  {
    key = 'Space',
    mods = 'CTRL|SHIFT',
    action = ime_helper.toggle()
  }
}

return config
