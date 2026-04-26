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
    vim.cmd.colorscheme(scheme)
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
      vim.schedule(apply_theme)
      vim.api.nvim_create_autocmd("FocusGained", {
        group = vim.api.nvim_create_augroup("tinted_theme_sync", { clear = true }),
        callback = apply_theme,
      })
    end,
  },
  -- habamax is a Neovim builtin: loads cleanly so LazyVim emits no warning,
  -- then vim.schedule above overrides it with the real scheme.
  { "LazyVim/LazyVim", opts = { colorscheme = "habamax" } },
}
