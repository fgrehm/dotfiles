return {
  -- Slim template language support
  {
    "slim-template/vim-slim",
    ft = "slim",
  },

  -- Add Slim treesitter parser
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed or {}, {
        "slim",
      })
    end,
  },

  -- Add Slim filetype detection and basic settings
  {
    "LazyVim/LazyVim",
    opts = function()
      -- Set up Slim filetype detection
      vim.filetype.add({
        extension = {
          slim = "slim",
        },
      })

      -- Slim-specific settings
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "slim",
        callback = function()
          vim.opt_local.shiftwidth = 2
          vim.opt_local.tabstop = 2
          vim.opt_local.softtabstop = 2
          vim.opt_local.expandtab = true
        end,
      })
    end,
  },
}
