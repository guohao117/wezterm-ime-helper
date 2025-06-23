# WezTerm IME Helper

A comprehensive solution for intelligent Input Method Editor (IME) switching across WezTerm terminal and Neovim editor.

## 🎯 Overview

This project provides two complementary plugins:

1. **WezTerm Plugin** (`plugin/`): Native WezTerm plugin for terminal-based IME switching
2. **Neovim Plugin** (`nvim/`): Automatic English switching for all non-insert modes

Together, they create a seamless experience where your IME automatically switches to English for Vim commands while preserving your input method preferences in insert mode.

## ✨ Features

### WezTerm Plugin Features

- **Cross-platform IME switching**: Supports macOS, Windows, and Linux
- **Multiple trigger methods**: Key bindings, command palette, OSC sequences
- **Toast notifications**: Visual feedback for IME changes
- **Remote session support**: Works with SSH and container environments
- **Command palette integration**: Easy manual IME switching

### Neovim Plugin Features

- **Auto-English in command modes**: Ensures all non-insert modes use English
- **Non-intrusive insert mode**: Preserves user's IME choice in insert mode
- **WezTerm integration**: Seamless communication via OSC sequences
- **Zero configuration**: Works out of the box with sensible defaults

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

### Neovim Plugin

Using **lazy.nvim**:
```lua
{
  "guohao117/wezterm-ime-helper",
  dir = "nvim", -- Use the nvim subdirectory
  event = "VeryLazy",
  cond = function()
    return vim.env.WEZTERM_PANE ~= nil
  end,
  config = function()
    require("ime-helper").setup()
  end,
}
```

Using **packer.nvim**:
```lua
use {
  "guohao117/wezterm-ime-helper", 
  rtp = "nvim",
  config = function()
    require("ime-helper").setup()
  end
}
```

Using **vim-plug**:
```vim
Plug 'guohao117/wezterm-ime-helper', {'rtp': 'nvim'}
```

## 🚀 Usage

### Basic Workflow

1. **Normal/Visual/Command modes**: Automatically uses English for Vim commands
2. **Insert mode**: Preserves whatever IME state you set through your OS
3. **Mode transitions**: Seamlessly switches to English when leaving insert mode
4. **Manual override**: Use commands or key bindings for temporary switches

### WezTerm Key Bindings (Local Usage)

If configured as shown above:
- `Ctrl+Alt+E`: Switch to English
- `Ctrl+Alt+I`: Switch to IME

### WezTerm Command Palette

1. Press `Ctrl+Shift+P` (or `Cmd+Shift+P` on macOS)
2. Type "IME" to see available switching options
3. Select your desired action

### Neovim Commands

- `:IMESwitchToEN` - Switch to English
- `:IMESwitchToIME` - Switch to IME
- `:IMEStatus` - Show current status

### OSC Sequences (Remote/Advanced Usage)

For remote sessions or manual integration:

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

### Neovim Plugin Configuration

```lua
require("ime-helper").setup({
  -- Enable debug logging
  debug = false,
  
  -- Enable automatic switching (disable if you want manual control only)
  auto_switch = true,
})
```

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
- **Neovim 0.7+** (for Neovim plugin)

## 🛠️ Troubleshooting

### Debug Mode

**Neovim Plugin**:
```lua
require("ime-helper").setup({ debug = true })
```

**WezTerm Plugin**:
```lua
ime_helper.setup({ log_level = "debug" })
```

### Common Issues

1. **IME not switching in Neovim**:
   - Check if both WezTerm and Neovim plugins are installed
   - Verify you're using WezTerm terminal
   - Enable debug mode to see OSC sequences

2. **Plugin not loading**:
   - Ensure `WEZTERM_PANE` environment variable is set (check with `:echo $WEZTERM_PANE`)
   - Check plugin installation path

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
- 🌏 Multilingual developers who code in English but write comments/docs in other languages
- ✍️ Technical writers who switch between languages
- 🚀 Anyone who wants Vim commands to always work in English
- 🔄 Users working in remote sessions where local IME control isn't available

## 🎮 How It Works

### Simple Workflow
1. **Start Neovim** → Automatically switches to English
2. **Enter insert mode** → Keeps whatever IME you've set via OS
3. **Exit insert mode** → Automatically switches back to English
4. **Manual switching** → Available via commands and key bindings

### Technical Details
The Neovim plugin sends OSC 1337 sequences to WezTerm:
- `IME_CONTROL=RU4=` (EN in base64) for English
- `IME_CONTROL=SU1F` (IME in base64) for IME

The WezTerm plugin receives these sequences and performs actual IME switching using platform-specific tools.

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
- Designed for [Neovim](https://neovim.io/) users who love automation

---

**Experience seamless multilingual editing with intelligent IME switching! 🎉**