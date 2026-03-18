-- vim-visual-multi: Multi-cursor support (Ctrl+N style)
return {
  {
    "mg979/vim-visual-multi",
    branch = "master",
    init = function()
      vim.g.VM_maps = {
        ["Find Under"] = "<C-n>", -- Start multi-cursor, add next match
        ["Find Subword Under"] = "<C-n>",
        ["Select All"] = "<C-A-n>", -- Select all matches
        ["Skip Region"] = "<C-x>", -- Skip current match
        ["Remove Region"] = "<C-p>", -- Go back to previous match
      }
    end,
  },
}
