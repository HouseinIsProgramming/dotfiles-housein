return {
  'karb94/neoscroll.nvim',
  lazy =false,
  config = function()
    local neoscroll = require 'neoscroll'
    local scroll = neoscroll.scroll

    local easing = 'sine'
    local zz_time_ms = 150
    local jump_time_ms = 200

    local centering_function = function()
      vim.defer_fn(function()
        require('neoscroll').zz {
          half_win_duration = zz_time_ms,
          easing = easing, -- e.g., "sine"
          winid = 0, -- optional, but recommended
        }
      end, 10)
    end

    neoscroll.setup {
      mappings = {
        '<C-u>',
        '<C-d>',
        '<C-b>',
        '<C-f>',
        '<C-y>',
        '<C-e>',
        'zt',
        'zz',
        'zb',
      },
      hide_cursor = false,
      stop_eof = false,
      respect_scrolloff = false,
      cursor_scrolls_alone = true,
      duration_multiplier = 0.5,
      easing = 'linear',
      performance_mode = false,
      ignored_events = { 'WinScrolled', 'CursorMoved' },
      post_hook = function(info)
        if info == 'center' then
          centering_function()
        end
      end,
    }

    vim.keymap.set('n', '<C-u>', function()
      scroll(-vim.wo.scroll, {
        move_cursor = true,
        duration = jump_time_ms, -- ✅ fixed here
        easing = easing,
        info = 'center',
      })
    end)

    vim.keymap.set('n', '<C-d>', function()
      scroll(vim.wo.scroll, {
        move_cursor = true,
        duration = jump_time_ms, -- ✅ fixed here
        easing = easing,
        info = 'center',
      })
    end)
  end,
}
