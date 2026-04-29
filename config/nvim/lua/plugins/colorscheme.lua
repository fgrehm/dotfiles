local DEFAULT = "base16-gruvbox-dark-hard"

local function read_theme()
  local wid = os.getenv("ALACRITTY_WINDOW_ID")
  if wid then
    local f = io.open((os.getenv("XDG_RUNTIME_DIR") or "/tmp") .. "/theme/window-" .. wid, "r")
    if f then
      local s = vim.trim(f:read("*l") or "")
      f:close()
      if s ~= "" then return s end
    end
  end
  local f = io.open(os.getenv("HOME") .. "/.local/share/theme/current", "r")
  if f then
    local s = vim.trim(f:read("*l") or "")
    f:close()
    if s ~= "" then return s end
  end
  return DEFAULT
end

local function apply_theme()
  local scheme = read_theme()
  if vim.g.colors_name ~= scheme then
    pcall(vim.cmd.colorscheme, scheme)
  end
end

-- Snacks links PathHidden/PathIgnored to NonText, which on base16/tinted is
-- base03 and unreadable in the explorer tree. Pull a brighter fg from Comment
-- (or fall back to Normal) and italicize so hidden entries stay distinct.
local function patch_snacks_hidden()
  local function fg(name)
    local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
    return hl and hl.fg
  end
  local color = fg("Comment") or fg("Normal")
  if not color then return end
  for _, group in ipairs({ "SnacksPickerPathHidden", "SnacksPickerPathIgnored" }) do
    vim.api.nvim_set_hl(0, group, { fg = color, italic = true })
  end
end

return {
  {
    "tinted-theming/tinted-nvim",
    lazy = false,
    priority = 1000,
    opts = {
      default_scheme = DEFAULT,
      selector = {
        enabled = true,
        mode = "file",
        path = os.getenv("HOME") .. "/.local/share/theme/current",
        watch = true,
      },
    },
    config = function(_, opts)
      require("tinted-nvim").setup(opts)
      -- Deferred so it runs after LazyVim applies its (builtin) colorscheme
      vim.schedule(function()
        apply_theme()
        patch_snacks_hidden()
      end)
      local group = vim.api.nvim_create_augroup("tinted_theme_sync", { clear = true })
      vim.api.nvim_create_autocmd("FocusGained", {
        group = group,
        callback = apply_theme,
      })
      vim.api.nvim_create_autocmd("ColorScheme", {
        group = group,
        callback = patch_snacks_hidden,
      })
    end,
  },
  -- tinted-nvim ships lua/lualine/themes/tinted.lua which references highlight
  -- groups it manages. Use it explicitly so lualine never tries to load the
  -- bundled base16 theme (which requires the absent RRethy/nvim-base16).
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      opts.options = opts.options or {}
      opts.options.theme = "tinted"
    end,
  },
  -- habamax is a Neovim builtin: loads cleanly so LazyVim emits no warning,
  -- then vim.schedule above overrides it with the real scheme.
  { "LazyVim/LazyVim", opts = { colorscheme = "habamax" } },
}
