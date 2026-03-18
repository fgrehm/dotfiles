return {
  "cappyzawa/trim.nvim",
  opts = {
    -- exclude the current line from trimming
    -- useful when used with auto-save plugins to avoid deleting auto-indentation
    trim_current_line = false,

    -- preserve final newline at end of file
    trim_last_line = false,

    -- TODO: highlight trailing space but prevent it from running on the lazyvim initial screen
    -- highlight = true,
  },
}
