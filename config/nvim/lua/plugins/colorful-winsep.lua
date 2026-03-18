return {
  {
    "nvim-zh/colorful-winsep.nvim",
    event = { "WinNew" },
    config = function()
      require("colorful-winsep").setup({
        border = "double",
        excluded_ft = { "packer", "TelescopePrompt", "mason" },
        highlight = "#00d9ff",  -- bright cyan
        animate = {
          enabled = true,
          duration = 300,
          easing = "in_out_cubic",
        },
      })
    end,
  },
}
