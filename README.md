# WezTerm IME Helper

A comprehensive solution for intelligent Input Method Editor (IME) switching in WezTerm terminal.

## 🎯 Overview

This project provides a native WezTerm plugin for seamless IME switching with multiple trigger methods including key bindings, command palette, and OSC sequences.

Perfect for multilingual users who need reliable IME control in terminal environments, including remote sessions.

## ✨ Features

- **Cross-platform IME switching**: Supports macOS, Windows, and Linux
- **Multiple trigger methods**: Key bindings, command palette, OSC sequences
- **Toast notifications**: Visual feedback for IME changes
- **Remote session support**: Works with SSH and container environments
- **Command palette integration**: Easy manual IME switching
- **Neovim integration**: Works with [noime.nvim](https://github.com/guohao117/noime.nvim) for automatic mode switching

## 📦 Installation

### WezTerm Plugin

Add to your `wezterm.lua` configuration:

```lua
local wezterm = require('wezterm')
local ime_helper = wezterm.plugin.require('https://github.com/guohao117/wezterm-ime-helper')

local config = wezterm.config_builder()

ime_helper.setup({
  auto_switch = true,
  ime_mapping = {
    macOS = {
      EN = "com.apple.keylayout.ABC",
      IME = "com.apple.inputmethod.SCIM.ITABC"
    }
  }
})

-- Optional: Add key bindings
config.keys = {
  { key = 'e', mods = 'CTRL|ALT', action = ime_helper.switch_to_en() },
  { key = 'i', mods = 'CTRL|ALT', action = ime_helper.switch_to_ime() },
}

return config
```

### Neovim Integration

For automatic IME switching in Neovim, install the companion plugin:

```lua
-- Using lazy.nvim
{
  "guohao117/noime.nvim",
  event = "VeryLazy",
  cond = function()
    return vim.env.WEZTERM_PANE ~= nil or (vim.env.TERM and vim.env.TERM:match("wezterm"))
  end,
  opts = {
    debug = false,
    auto_switch = true,
  },
  config = function(_, opts)
    require("ime-helper").setup(opts)
  end,
  keys = {
    {
      "<leader>uie",
      function()
        require("ime-helper").switch_to_en()
      end,
      desc = "IME: Switch to English",
    },
    {
      "<leader>uii",
      function()
        require("ime-helper").switch_to_ime()
      end,
      desc = "IME: Switch to IME",
    },
    {
      "<leader>uis",
      function()
        require("ime-helper").status()
      end,
      desc = "IME: Show Status",
    },
  },
}
```

For **LazyVim users**, create a file at `~/.config/nvim/lua/plugins/wezterm-ime-helper.lua`:
```lua
return {
  {
    "guohao117/noime.nvim",
    event = "VeryLazy",
    cond = function()
      return vim.env.WEZTERM_PANE ~= nil or (vim.env.TERM and vim.env.TERM:match("wezterm"))
    end,
    config = function()
      require("ime-helper").setup()
    end,
  },
}
```

## 🚀 Usage

### WezTerm Key Bindings (Local Usage)

If configured as shown above:
- `Ctrl+Alt+E`: Switch to English
- `Ctrl+Alt+I`: Switch to IME

### WezTerm Command Palette

1. Press `Ctrl+Shift+P` (or `Cmd+Shift+P` on macOS)
2. Type "IME" to see available switching options
3. Select your desired action

### OSC Sequences (Remote/Advanced Usage)

For remote sessions or integration with other tools:

```bash
# Switch to English (EN -> RU4=)
printf '\033]1337;SetUserVar=IME_CONTROL=RU4=\007'

# Switch to IME (IME -> SU1F)  
printf '\033]1337;SetUserVar=IME_CONTROL=SU1F\007'
```

**PowerShell:**
```powershell
Write-Host "`e]1337;SetUserVar=IME_CONTROL=RU4=`a" -NoNewline  # Switch to EN
Write-Host "`e]1337;SetUserVar=IME_CONTROL=SU1F`a" -NoNewline  # Switch to IME
```

## ⚙️ Configuration

### WezTerm Plugin Configuration

```lua
ime_helper.setup({
  auto_switch = true,
  log_level = "info",
  enable_command_palette = true, -- Enable command palette integration
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
```

### IME Identifier Reference

#### macOS
Use `macism list` to see available input sources:
```bash
brew install macism
macism list
```

Common examples:
- `com.apple.keylayout.ABC` - ABC (English)
- `com.apple.inputmethod.SCIM.ITABC` - Pinyin (Simplified Chinese)
- `com.apple.inputmethod.TCIM.Cangjie` - Cangjie (Traditional Chinese)
- `com.apple.inputmethod.Kotoeri.RomajiTyping.Japanese` - Japanese

#### Windows
Use Windows Language Code Identifiers (LCID):
- `1033` - English (US)
- `2052` - Chinese (Simplified, PRC)
- `1028` - Chinese (Traditional, Taiwan)
- `1041` - Japanese

#### Linux
Use IBus or Fcitx engine names:

For IBus:
```bash
ibus list-engine
```

For Fcitx:
```bash
fcitx-diagnose
```

Common examples:
- `xkb:us::eng` - English (US)
- `pinyin` - Pinyin (Chinese)
- `anthy` - Anthy (Japanese)

## 📋 Requirements

### System Requirements

**macOS**:
- Install `macism`: `brew install macism`

**Windows**:
- Install `im-select` from [daipeihust/im-select](https://github.com/daipeihust/im-select)
  - Download the latest release and add `im-select.exe` to your PATH
  - Or try `scoop install im-select`

**Linux**:
- IBus or Fcitx input method framework
- Ensure `ibus-daemon` or `fcitx`/`fcitx5` is running

### Software Requirements

- **WezTerm terminal** (latest version recommended)

## 🛠️ Troubleshooting

### Debug Mode

**WezTerm Plugin**:
```lua
ime_helper.setup({ log_level = "debug" })
```

### Common Issues

1. **IME not switching**:
   - Verify your IME identifiers are correct
   - Check that required system tools are installed (macism, im-select, etc.)
   - Enable debug mode to see detailed logs

2. **OSC sequences not working**:
   - Ensure you're using WezTerm terminal
   - Test sequences manually in terminal

3. **Manual testing**:
   ```bash
   # Test OSC sequences directly
   printf '\033]1337;SetUserVar=IME_CONTROL=RU4=\007'  # Switch to EN
   printf '\033]1337;SetUserVar=IME_CONTROL=SU1F\007'  # Switch to IME
   ```

### Platform-specific Issues

**macOS**: Ensure `macism` is installed and your IME identifiers are correct  
**Windows**: May require administrator privileges for some IME operations  
**Linux**: Ensure your input method framework is properly configured and running

## 🎯 Use Cases

**Perfect for**:
- 🌏 Multilingual terminal users who need reliable IME switching
- ✍️ Users working in remote sessions where local IME control isn't available
- 🚀 Developers who want programmatic IME control via OSC sequences
- 🔄 Anyone using Neovim with the companion [noime.nvim](https://github.com/guohao117/noime.nvim) plugin

## 🎮 How It Works

### Technical Details
The plugin receives OSC 1337 sequences with user variables:
- `IME_CONTROL=RU4=` (EN in base64) for English
- `IME_CONTROL=SU1F` (IME in base64) for IME

It then uses platform-specific tools to perform actual IME switching:
- **macOS**: `macism` command-line tool
- **Windows**: `im-select.exe` utility
- **Linux**: IBus or Fcitx commands

## 🤝 Contributing

Contributions are welcome! Please feel free to:
- Report bugs or request features
- Submit pull requests
- Improve documentation
- Share usage examples

## 📄 License

MIT License

## 🙏 Acknowledgments

- Inspired by [im-select.nvim](https://github.com/keaising/im-select.nvim)
- Built for the amazing [WezTerm](https://wezfurlong.org/wezterm/) terminal
- Companion Neovim plugin: [noime.nvim](https://github.com/guohao117/noime.nvim)

---

**Experience seamless multilingual terminal usage with intelligent IME switching! 🎉**