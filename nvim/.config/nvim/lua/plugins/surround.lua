return {
  'nvim-mini/mini.surround',
  version = false,
  opts = {
    custom_surroundings = nil,
    highlight_duration = 1500,
    mappings = {
      add         = 'gsa', -- Add surrounding in Normal and Visual modes
      delete      = 'gsd', -- Delete surrounding
      find        = 'gsf', -- Find surrounding (to the right)
      find_left   = 'gsF', -- Find surrounding (to the left)
      highlight   = 'gsh', -- Highlight surrounding
      replace     = 'gsr', -- Replace surrounding

      suffix_last = 'l',   -- Suffix to search with "prev" method
      suffix_next = 'n',   -- Suffix to search with "next" method
    },

    -- Number of lines within which surrounding is searched
    n_lines = 20,

    -- Whether to respect selection type:
    -- - Place surroundings on separate lines in linewise mode.
    -- - Place surroundings on each line in blockwise mode.
    respect_selection_type = false,

    -- How to search for surrounding (first inside current line, then inside
    -- neighborhood). One of 'cover', 'cover_or_next', 'cover_or_prev',
    -- 'cover_or_nearest', 'next', 'prev', 'nearest'. For more details,
    -- see `:h MiniSurround.config`.
    search_method = 'cover',

    -- Whether to disable showing non-error feedback
    -- This also affects (purely informational) helper messages shown after
    -- idle time if user input is required.
    silent = false,
  }
}
