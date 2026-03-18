-- Configure blink.cmp for Tab navigation and Enter to select
return {
  {
    "saghen/blink.cmp",
    opts = {
      keymap = {
        ["<C-e>"] = { "cancel" },
        ["<Tab>"] = { "select_next", "fallback" },
        ["<S-Tab>"] = { "select_prev", "fallback" },
        ["<CR>"] = { "accept", "fallback" },
      },
    },
  },
}
