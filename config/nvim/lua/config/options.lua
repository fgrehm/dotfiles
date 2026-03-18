-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Me no like relative line numbers
vim.opt.relativenumber = false

-- OSC 52 clipboard over SSH - copy only
-- Yank (y) copies to system clipboard via OSC 52
-- Paste (p) uses nvim's internal registers only (OSC 52 paste doesn't work reliably)
-- For pasting from system clipboard, use terminal paste (Ctrl+Shift+V in insert mode)
local osc52 = require("vim.ui.clipboard.osc52")
vim.g.clipboard = {
  name = "OSC 52",
  copy = {
    ["+"] = osc52.copy("+"),
    ["*"] = osc52.copy("*"),
  },
  paste = {
    ["+"] = function()
      return vim.split(vim.fn.getreg('"'), "\n")
    end,
    ["*"] = function()
      return vim.split(vim.fn.getreg('"'), "\n")
    end,
  },
}

if vim.env.LSP_DEBUG then
  vim.lsp.set_log_level("debug")
end
