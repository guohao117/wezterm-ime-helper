# WezTerm IME Helper Plugin

A WezTerm plugin that provides intelligent Input Method Editor (IME) switching capabilities, designed to work seamlessly with both local and remote editing sessions through OSC sequences.

## Features

- **Cross-platform IME switching**: Supports macOS, Windows, and Linux
- **OSC sequence support**: Works with remote sessions via escape sequences
- **Neovim integration ready**: Designed to work with Neovim plugins for mode-based IME switching
- **User variable support**: Compatible with existing WezTerm user variable workflows
- **Command palette integration**: Easy manual IME switching through WezTerm's command palette
- **Modular architecture**: Clean separation of concerns with proper module loading

## Installation

Add to your `wezterm.lua` configuration file:

```lua
local wezterm = require('wezterm')
local ime_helper = wezterm.plugin.require('https://github.com/guohaodev/wezterm-ime-helper')

local config = wezterm.config_builder()

-- Setup IME helper
ime_helper.setup({
  auto_switch = true,
  log_level = "info",
  ime_mapping = {
    macOS = {
      EN = "com.apple.keylayout.ABC",
      IME = "com.apple.inputmethod.SCIM.ITABC"  -- or your preferred Chinese IME
    },
    Windows = {
      EN = "0x0409",  -- English (US)
      IME = "0x0804"  -- Chinese (Simplified)
    },
    Linux = {
      EN = "xkb:us::eng",
      IME = "pinyin"  -- or your preferred IME engine
    }
  }
})

return config
```

## Usage

### Via OSC Sequences (Recommended for Neovim integration)

The plugin listens for WezTerm user variables that can be set via OSC sequences:

```bash
# Switch to English
printf '\033]1337;SetUserVar=IME_CONTROL=EN\007'

# Switch to IME  
printf '\033]1337;SetUserVar=IME_CONTROL=IME\007'
```

### Via Command Palette

1. Press `Ctrl+Shift+P` (or `Cmd+Shift+P` on macOS) to open WezTerm's command palette
2. Type "IME" to see available switching options:
   - "Switch to English IME" 
   - "Switch to IME"

### Supported User Variables

The plugin responds to the following user variable names:
- `IME_CONTROL` (recommended)
- `wezterm_ime_control` (for backward compatibility)

## Neovim Integration

Create a Neovim plugin or add to your configuration:

### Basic Integration

```lua
-- Switch to English when leaving insert mode
vim.api.nvim_create_autocmd("InsertLeave", {
  callback = function()
    io.write('\027]1337;SetUserVar=IME_CONTROL=EN\007')
    io.flush()
  end
})

-- Switch to IME when entering insert mode in text files
vim.api.nvim_create_autocmd("InsertEnter", {
  pattern = {"*.md", "*.txt", "*.tex"},
  callback = function()
    io.write('\027]1337;SetUserVar=IME_CONTROL=IME\007')
    io.flush()
  end
})
```

### Advanced Integration with Filetype Detection

```lua
local ime_filetypes = {"markdown", "text", "gitcommit", "tex"}

local function switch_ime(state)
  io.write(string.format('\027]1337;SetUserVar=IME_CONTROL=%s\007', state))
  io.flush()
end

local group = vim.api.nvim_create_augroup("WezTermIME", { clear = true })

-- Always switch to English when leaving insert mode
vim.api.nvim_create_autocmd("InsertLeave", {
  group = group,
  callback = function() switch_ime("EN") end
})

-- Switch to IME for specific filetypes
vim.api.nvim_create_autocmd("InsertEnter", {
  group = group,
  pattern = vim.tbl_map(function(ft) return "*." .. ft end, ime_filetypes),
  callback = function() switch_ime("IME") end
})

-- Manual commands
vim.api.nvim_create_user_command("IMEEn", function() switch_ime("EN") end, {})
vim.api.nvim_create_user_command("IMECn", function() switch_ime("IME") end, {})
```

## Configuration Options

### `setup(opts)`

- `auto_switch` (boolean, default: `true`): Enable automatic IME switching
- `log_level` (string, default: `"info"`): Logging level for debugging
- `ime_mapping` (table): Custom IME identifier mappings per OS

### IME Mapping Configuration

The plugin uses platform-specific IME identifiers. You can customize these based on your system:

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
- `0x0409` - English (US)
- `0x0804` - Chinese (Simplified, PRC)
- `0x0404` - Chinese (Traditional, Taiwan)
- `0x0411` - Japanese

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

## Requirements

### macOS
- Install `macism`: `brew install macism`

### Windows
- PowerShell (included in Windows 10/11)

### Linux
- IBus or Fcitx input method framework
- For IBus: `ibus-daemon` must be running
- For Fcitx: `fcitx` or `fcitx5` must be running

## Troubleshooting

### Check if IME switching works
Test manually with:
```bash
printf '\033]1337;SetUserVar=IME_CONTROL=EN\007'
printf '\033]1337;SetUserVar=IME_CONTROL=IME\007'
```

### Enable debug logging
```lua
ime_helper.setup({
  log_level = "debug"
})
```

Then check WezTerm logs for detailed information.

### Platform-specific issues

**macOS**: Ensure `macism` is installed and your IME identifiers are correct
**Windows**: May require administrator privileges for some IME operations
**Linux**: Ensure your input method framework is properly configured and running

## License

MIT License