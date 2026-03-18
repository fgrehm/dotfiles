-- Snacks configuration
-- Explorer: Show hidden and gitignored files by default
-- File pickers (<space>ff, <space><space>): Show hidden files, respect .gitignore
return {
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        sources = {
          explorer = {
            hidden = true, -- Show hidden files (dotfiles)
            ignored = true, -- Show gitignored files
          },
          files = {
            hidden = true, -- Show hidden files in file picker
          },
        },
        matcher = {
          frecency = true,
        },
        sort = {
          -- Sort by last used
          fields = { "buf_lastused:desc", "score:desc", "#text", "idx" },
        },
      },
    },
  },
}
