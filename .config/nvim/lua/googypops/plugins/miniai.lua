return {
  'echasnovski/mini.ai',
	  lazy = false, -- Ensures it's loaded at startup
  opts = function()
    local ai = require 'mini.ai'
    return {
      n_lines = 500,
      custom_textobjects = {
        -- Code blocks, functions, classes
        o = ai.gen_spec.treesitter {
          a = { '@block.outer', '@conditional.outer', '@loop.outer' },
          i = { '@block.inner', '@conditional.inner', '@loop.inner' },
        },
        f = ai.gen_spec.treesitter { a = '@function.outer', i = '@function.inner' },
        c = ai.gen_spec.treesitter { a = '@class.outer', i = '@class.inner' },
        -- Tags, digits, word case
        t = { '<([%p%w]-)%f[^<%w][^<>]->.-</%1>', '^<.->().*()</[^/]->$' },
        d = { '%f[%d]%d+' },
        e = {
          { '%u[%l%d]+%f[^%l%d]', '%f[%S][%l%d]+%f[^%l%d]', '%f[%P][%l%d]+%f[^%l%d]', '^[%l%d]+%f[^%l%d]' },
          '^().*()$',
        },
        g = function()
          local from = { line = 1, col = 1 }
          local to = {
            line = vim.fn.line '$',
            col = math.max(vim.fn.getline('$'):len(), 1),
          }
          return { from = from, to = to }
        end,
      },
    }
  end,
}
