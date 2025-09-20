return { {
  'saghen/blink.cmp',
  dependencies = { 'rafamadriz/friendly-snippets' },
  version = '1.*',

  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
    keymap = { preset = 'super-tab' },
    appearance = {
      nerd_font_variant = 'mono'
    },
    completion = {
      menu = {
        window = { border = "rounded" },
        draw = {
          padding = { 1, 1 },
          components = {
            kind_icon = {
              text = function(ctx) return ' ' .. ctx.kind_icon .. ctx.icon_gap .. ' ' end
            }
          }
        }
      },
      documentation = { auto_show = true }
    },
    signature = { window = { border = 'single' } },

    -- Default list of enabled providers defined so that you can extend it
    -- elsewhere in your config, without redefining it, due to `opts_extend`
    sources = {
      default = { 'lsp', 'path', 'snippets', 'buffer' },
      providers = {
        snippets = {
          should_show_items = function(ctx)
            return ctx.trigger.initial_kind ~= 'trigger_character'
          end
        }
      }
    },
    fuzzy = { implementation = "prefer_rust_with_warning" }
  },
  opts_extend = { "sources.default" }
} }
