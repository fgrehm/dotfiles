local DEFAULT = "base16-gruvbox-dark-hard"

local function read_theme()
  local wid = os.getenv("ALACRITTY_WINDOW_ID")
  local runtime = os.getenv("XDG_RUNTIME_DIR") or "/tmp"
  if wid then
    local wf = io.open(runtime .. "/theme/window-" .. wid, "r")
    if wf then
      local s = vim.trim(wf:read("*l") or "")
      wf:close()
      if s ~= "" then return s end
    end
  end
  local gf = io.open(os.getenv("HOME") .. "/.local/share/theme/current", "r")
  if gf then
    local s = vim.trim(gf:read("*l") or "")
    gf:close()
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
    config = function()
      require("tinted-nvim").setup()
      vim.o.termguicolors = true
      vim.schedule(apply_theme)

      vim.api.nvim_create_autocmd("FocusGained", {
        group = vim.api.nvim_create_augroup("tinted_theme_sync", { clear = true }),
        callback = apply_theme,
      })

      -- Watch global theme file for changes while nvim has focus
      local uv = vim.uv or vim.loop
      local global_file = os.getenv("HOME") .. "/.local/share/theme/current"
      local handle = uv.new_fs_event()
      if handle then
        uv.fs_event_start(handle, global_file, {}, function()
          vim.schedule(apply_theme)
        end)
      end
    end,
  },
  { "LazyVim/LazyVim", opts = { colorscheme = "base16-gruvbox-dark-hard" } },
}
