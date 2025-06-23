# WezTerm IME Helper Plugin

A WezTerm plugin that provides intelligent Input Method Editor (IME) switching capabilities, designed to work seamlessly with both local terminal usage and remote editing sessions.

## Features

- **Cross-platform IME switching**: Supports macOS, Windows, and Linux
- **Direct function calls**: Efficient IME switching through WezTerm's action system
- **OSC sequence support**: Compatible with remote sessions via escape sequences
- **Neovim integration ready**: Designed to work with Neovim plugins for mode-based IME switching
- **Command palette integration**: Easy manual IME switching through WezTerm's command palette
- **Toast notifications**: Visual feedback when switching IME states
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
config.keys = {
  -- Switch to English
  {
    key = 'e',
    mods = 'CTRL|ALT',
    action = ime_helper.switch_to_en()
  },
  -- Switch to IME  
  {
    key = 'i',
    mods = 'CTRL|ALT',
    action = ime_helper.switch_to_ime()
  },
  -- Toggle between EN and IME
  {
    key = 't',
    mods = 'CTRL|ALT',
    action = ime_helper.toggle()
  }
}

return config
```

## Usage

### Via Key Bindings (Recommended for local use)

If you've configured key bindings as shown above:
- `Ctrl+Alt+E`: Switch to English
- `Ctrl+Alt+I`: Switch to IME
- `Ctrl+Alt+T`: Toggle between English and IME

### Via Command Palette

1. Press `Ctrl+Shift+P` (or `Cmd+Shift+P` on macOS) to open WezTerm's command palette
2. Type "IME" to see available switching options

### Via OSC Sequences (For remote/Neovim integration)

The plugin listens for WezTerm user variables that can be set via OSC sequences. Note that the variable values must be base64 encoded:

```bash
# Switch to English (EN -> RU4=)
printf '\033]1337;SetUserVar=IME_CONTROL=RU4=\007'

# Switch to IME (IME -> SU1F)  
printf '\033]1337;SetUserVar=IME_CONTROL=SU1F\007'
```

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
    io.write('\027]1337;SetUserVar=IME_CONTROL=RU4=\007')  -- "EN" base64 encoded
    io.flush()
  end
})

-- Switch to IME when entering insert mode in text files
vim.api.nvim_create_autocmd("InsertEnter", {
  pattern = {"*.md", "*.txt", "*.tex"},
  callback = function()
    io.write('\027]1337;SetUserVar=IME_CONTROL=SU1F\007')  -- "IME" base64 encoded
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
- Install `im-select`: Download from [daipeihust/im-select](https://github.com/daipeihust/im-select)
  - **Option 1 - Manual**: Download the latest release from the GitHub releases page, extract `im-select.exe` and add it to your PATH (recommended)
  - **Option 2 - Scoop**: Try `scoop install im-select` (may need to add additional buckets or may not be available)
  - **Option 3 - Build from source**: Clone the repository and build yourself

### Linux
- IBus or Fcitx input method framework
- For IBus: `ibus-daemon` must be running
- For Fcitx: `fcitx` or `fcitx5` must be running

## Troubleshooting

### Check if IME switching works
Test manually with:

**Bash/Zsh:**
```bash
printf '\033]1337;SetUserVar=IME_CONTROL=RU4=\007'  # Switch to EN
printf '\033]1337;SetUserVar=IME_CONTROL=SU1F\007'  # Switch to IME
```

**PowerShell:**
```powershell
Write-Host "`e]1337;SetUserVar=IME_CONTROL=RU4=`a" -NoNewline  # Switch to EN
Write-Host "`e]1337;SetUserVar=IME_CONTROL=SU1F`a" -NoNewline  # Switch to IME
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