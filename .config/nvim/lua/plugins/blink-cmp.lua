-- Set up blue Atom-like highlight groups
vim.api.nvim_create_autocmd({ 'ColorScheme', 'VimEnter' }, {
  group = vim.api.nvim_create_augroup('BlinkCmpColors', { clear = true }),
  callback = function()
    -- Main menu colors with blue tones
    vim.api.nvim_set_hl(0, 'BlinkCmpMenu', { bg = '#1e2124', fg = '#c9d1d9' })
    vim.api.nvim_set_hl(0, 'BlinkCmpMenuBorder', { fg = '#58a6ff', bg = '#1e2124' })
    vim.api.nvim_set_hl(0, 'BlinkCmpMenuSelection', { bg = '#264f78', fg = '#ffffff' })

    -- Scrollbar with blue accents
    vim.api.nvim_set_hl(0, 'BlinkCmpScrollBarThumb', { bg = '#58a6ff' })
    vim.api.nvim_set_hl(0, 'BlinkCmpScrollBarGutter', { bg = '#21262d' })

    -- Label styling with blue highlights
    vim.api.nvim_set_hl(0, 'BlinkCmpLabel', { fg = '#c9d1d9', bg = 'NONE' })
    vim.api.nvim_set_hl(0, 'BlinkCmpLabelMatch', { fg = '#58a6ff', bold = true })
    vim.api.nvim_set_hl(0, 'BlinkCmpLabelDetail', { fg = '#7d8590' })
    vim.api.nvim_set_hl(0, 'BlinkCmpLabelDescription', { fg = '#8b949e' })
    vim.api.nvim_set_hl(0, 'BlinkCmpLabelDeprecated', { fg = '#6e7681', strikethrough = true })

    -- Kind icons with blue theme (no background to match text)
    vim.api.nvim_set_hl(0, 'BlinkCmpKind', { fg = '#79c0ff' })

    -- Specific kind highlights with different blue shades
    vim.api.nvim_set_hl(0, 'BlinkCmpKindFunction', { fg = '#d2a8ff' })
    vim.api.nvim_set_hl(0, 'BlinkCmpKindMethod', { fg = '#d2a8ff' })
    vim.api.nvim_set_hl(0, 'BlinkCmpKindVariable', { fg = '#79c0ff' })
    vim.api.nvim_set_hl(0, 'BlinkCmpKindKeyword', { fg = '#ff7b72' })
    vim.api.nvim_set_hl(0, 'BlinkCmpKindText', { fg = '#f0f6fc' })
    vim.api.nvim_set_hl(0, 'BlinkCmpKindSnippet', { fg = '#a5f3fc' })
    vim.api.nvim_set_hl(0, 'BlinkCmpKindClass', { fg = '#ffa657' })
    vim.api.nvim_set_hl(0, 'BlinkCmpKindInterface', { fg = '#ffa657' })

    -- Source name with blue accent
    vim.api.nvim_set_hl(0, 'BlinkCmpSource', { fg = '#58a6ff', italic = true })

    -- Documentation window with blue theme
    vim.api.nvim_set_hl(0, 'BlinkCmpDoc', { bg = '#1F2124', fg = '#c9d1d9' })
    vim.api.nvim_set_hl(0, 'BlinkCmpDocBorder', { fg = '#161b22', bg = '#161b22' })
    vim.api.nvim_set_hl(0, 'BlinkCmpDocSeparator', { fg = '#21262d' })
    vim.api.nvim_set_hl(0, 'BlinkCmpDocCursorLine', { bg = '#264f78' })

    -- Signature help with blue theme
    vim.api.nvim_set_hl(0, 'BlinkCmpSignatureHelp', { bg = '#161b22', fg = '#c9d1d9' })
    vim.api.nvim_set_hl(0, 'BlinkCmpSignatureHelpBorder', { fg = '#58a6ff', bg = '#161b22' })
    vim.api.nvim_set_hl(0, 'BlinkCmpSignatureHelpActiveParameter', { fg = '#79c0ff', bold = true, underline = true })

    -- Ghost text with subtle blue
    vim.api.nvim_set_hl(0, 'BlinkCmpGhostText', { fg = '#484f58', italic = true })
  end,
})

return { {
  'saghen/blink.cmp',
  dependencies = {
    'rafamadriz/friendly-snippets',
    'L3MON4D3/LuaSnip',
  },
  version = '1.*',

  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
    keymap = { preset = 'super-tab', ['<C-l>'] = { function(cmp) cmp.show() end },
    },
    appearance = {
      nerd_font_variant = 'mono'
    },
    completion = {
      menu = {
        border = 'solid',
        winhighlight = 'Normal:BlinkCmpMenu,FloatBorder:BlinkCmpMenuBorder,CursorLine:BlinkCmpMenuSelection,Search:None',
        draw = {
          padding = { 0, 0 },
          components = {
            kind_icon = {
              text = function(ctx) return ctx.kind_icon .. ctx.icon_gap .. ' ' end,
              highlight = function(ctx)
                local text = ' ' .. ctx.kind_icon .. ctx.icon_gap .. ' '
                return { { 0, #text, group = ctx.kind_hl or 'BlinkCmpKind', priority = 20000 } }
              end,
            }
          }
        }
      },
      documentation = {
        auto_show = true,
        window = {
          border = 'solid',
          winhighlight = 'Normal:BlinkCmpDoc,FloatBorder:BlinkCmpDocBorder,CursorLine:BlinkCmpDocCursorLine',
        }
      }
    },
    signature = {
      window = {
        border = 'solid',
        winhighlight = 'Normal:BlinkCmpSignatureHelp,FloatBorder:BlinkCmpSignatureHelpBorder',
      }
    },

    -- Default list of enabled providers defined so that you can extend it
    -- elsewhere in your config, without redefining it, due to `opts_extend`
    sources = {
      default = { 'lsp', 'path', 'snippets', 'buffer' },
    },
    fuzzy = { implementation = "prefer_rust_with_warning" }
  },
  opts_extend = { "sources.default" }
} }
