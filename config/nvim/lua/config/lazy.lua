local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

local options = {
  spec = {
    -- add LazyVim and import its plugins
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },
    -- import/override with your plugins
    { import = "plugins" },
  },
  defaults = {
    -- By default, only LazyVim plugins will be lazy-loaded. Your custom plugins will load during startup.
    -- If you know what you're doing, you can set this to `true` to have all your custom plugins lazy-loaded by default.
    lazy = false,
    -- It's recommended to leave version=false for now, since a lot the plugin that support versioning,
    -- have outdated releases, which may break your Neovim install.
    version = false, -- always use the latest git commit
    -- version = "*", -- try installing the latest stable version for plugins that support semver
  },
  install = { colorscheme = { "tokyonight", "habamax" } },
  checker = {
    enabled = true, -- check for plugin updates periodically
    notify = false, -- notify on update
  }, -- automatically check for plugin updates
  performance = {
    rtp = {
      -- disable some rtp plugins
      disabled_plugins = {
        "gzip",
        -- "matchit",
        -- "matchparen",
        -- "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
}

-- A provisioned guest's nvim config may be a symlink into a host-mounted
-- dotfiles checkout. Keep plugin lock updates in the guest home so they never
-- rewrite the host's shared lazy-lock.json.
local global_mise_config = vim.env.MISE_GLOBAL_CONFIG_FILE
local home = vim.env.HOME
if global_mise_config and home then
  local home_prefix = home .. "/"
  local config_is_external = global_mise_config ~= home and global_mise_config:sub(1, #home_prefix) ~= home_prefix
  if config_is_external then
    options.lockfile = vim.fn.stdpath("state") .. "/lazy-lock.json"
    local shared_lockfile = vim.fn.stdpath("config") .. "/lazy-lock.json"
    if vim.fn.filereadable(options.lockfile) == 0 and vim.fn.filereadable(shared_lockfile) == 1 then
      vim.fn.mkdir(vim.fn.fnamemodify(options.lockfile, ":h"), "p")
      vim.fn.writefile(vim.fn.readfile(shared_lockfile, "b"), options.lockfile, "b")
    end
  end
end

require("lazy").setup(options)
