local DEFAULT = "base16-gruvbox-dark-hard"

local function read_per_window()
  local wid = os.getenv("ALACRITTY_WINDOW_ID")
  if not wid then return nil end
  local f = io.open((os.getenv("XDG_RUNTIME_DIR") or "/tmp") .. "/theme/window-" .. wid, "r")
  if not f then return nil end
  local s = vim.trim(f:read("*l") or "")
  f:close()
  return s ~= "" and s or nil
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

      -- Per-window override: applied after global (deferred past LazyVim init)
      local pw = read_per_window()
      if pw then
        vim.schedule(function()
          vim.cmd.colorscheme(pw)
        end)
      end

      -- Re-check per-window on focus; global changes are handled by selector watcher
      vim.api.nvim_create_autocmd("FocusGained", {
        group = vim.api.nvim_create_augroup("tinted_theme_sync", { clear = true }),
        callback = function()
          local scheme = read_per_window()
          if scheme and vim.g.colors_name ~= scheme then
            vim.cmd.colorscheme(scheme)
          end
        end,
      })
    end,
  },
  { "LazyVim/LazyVim", opts = { colorscheme = "" } },
}
