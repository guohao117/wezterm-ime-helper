local wezterm = require('wezterm')

local M = {}

function M.setup(config)
  -- 注册命令面板增强
  wezterm.on('augment-command-palette', function(window, pane)
    return {
      {
        brief = 'Switch to English IME',
        icon = 'md_keyboard',
        action = wezterm.action.SetUserVar('IME_CONTROL', 'EN'),
      },
      {
        brief = 'Switch to IME',
        icon = 'md_translate',
        action = wezterm.action.SetUserVar('IME_CONTROL', 'IME'),
      },
    }
  end)
end

-- 生成OSC序列的辅助函数
function M.generate_ime_osc(state)
  return string.format('\x1b]1337;SetUserVar=IME_CONTROL=%s\x07', state)
end

return M