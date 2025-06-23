-- WezTerm IME Helper - Neovim Integration Example
-- Place this in your Neovim configuration

local M = {}

-- IME control functions
local function switch_to_en()
  io.write('\027]1337;SetUserVar=IME_CONTROL=EN\007')
  io.flush()
end

local function switch_to_ime()
  io.write('\027]1337;SetUserVar=IME_CONTROL=IME\007')
  io.flush()
end

-- Setup function
function M.setup(opts)
  opts = opts or {}
  
  local ime_filetypes = opts.ime_filetypes or {"markdown", "text", "gitcommit"}
  local auto_switch = opts.auto_switch ~= false
  
  if not auto_switch then
    return
  end

  local group = vim.api.nvim_create_augroup("WezTermIME", { clear = true })

  -- Switch to English when leaving insert mode
  vim.api.nvim_create_autocmd("InsertLeave", {
    pattern = "*",
    callback = switch_to_en,
    group = group
  })

  -- Switch to IME when entering insert mode in specific filetypes
  vim.api.nvim_create_autocmd("InsertEnter", {
    pattern = vim.tbl_map(function(ft) return "*." .. ft end, ime_filetypes),
    callback = switch_to_ime,
    group = group
  })

  -- Commands for manual control
  vim.api.nvim_create_user_command("IMEEn", switch_to_en, {})
  vim.api.nvim_create_user_command("IMEIME", switch_to_ime, {})
end

return M
