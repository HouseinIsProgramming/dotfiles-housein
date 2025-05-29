-- return {
--
--   "projekt0n/github-nvim-theme",
--   config = function()
--     vim.cmd("colorscheme github_dark_tritanopia")
--   end,
-- }
--
--
--
-- return {
--   "AlexvZyl/nordic.nvim",
--   lazy = false,
--   priority = 1000,
--   config = function()
--     vim.cmd("colorscheme nordic")
--   end,
-- }

-- return {
--   "folke/tokyonight.nvim",
--   priority = 1000,
--   config = function()
--     local transparent = true -- set to true if you would like to enable transparency
--     require("tokyonight").setup({
--       styles = {
--         sidebars = transparent and "transparent" or "dark",
--         floats = transparent and "transparent" or "dark",
--       },
--     })
--     vim.cmd("colorscheme tokyonight")
--   end,
-- }
--
return {
  {
    "catppuccin/nvim",
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "auto", -- latte, frappe, macchiato, mocha
        background = { -- :h background
          light = "latte",
          dark = "mocha",
        },
        transparent_background = false, -- disables setting the background color.
        show_end_of_buffer = false, -- shows the '~' characters after the end of buffers
        term_colors = false, -- sets terminal colors (e.g. `g:terminal_color_0`)
        dim_inactive = {
          enabled = true, -- dims the background color of inactive window
          shade = "dark",
          percentage = 0.15, -- percentage of the shade to apply to the inactive window
        },
        no_italic = false, -- Force no italic
        no_bold = false, -- Force no bold
        no_underline = false, -- Force no underline
        styles = { -- Handles the styles of general hi groups (see `:h highlight-args`):
          comments = { "italic" }, -- Change the style of comments
          conditionals = { "italic" },
          loops = {},
          functions = {},
          keywords = {},
          strings = {},
          variables = {},
          numbers = {},
          booleans = {},
          properties = {},
          types = {},
          operators = {},
          -- miscs = {}, -- Uncomment to turn off hard-coded styles
        },
        color_overrides = {},
        custom_highlights = {},
        default_integrations = true,
        integrations = {
          cmp = true,
          gitsigns = true,
          nvimtree = true,
          treesitter = true,
          notify = false,
          mini = {
            enabled = true,
            indentscope_color = "",
          },
          -- For more plugins integrations please scroll down (https://github.com/catppuccin/nvim#integrations)
        },

        -- setup must be called before loading
      })
    end,
  },
  { "kristijanhusak/vim-hybrid-material", priority = 1000 },

  { "arzg/vim-colors-xcode", priority = 1000 },

  {
    "projekt0n/github-nvim-theme",
    name = "github-theme",
    lazy = false,
    priority = 1000,
    config = function()
      require("github-theme").setup({
        -- options table remains here if you have other options
        options = {
          styles = {
            comments = "italic",
            keywords = "bold",
            types = "italic,bold",
          },
          darken = {
            sidebars = {
              floats = true,
              enable = true,
              list = {},
            },
          },
          -- Other options...
        },
        groups = {
          github_light_default = {
            Normal = {
              bg = "#EDEDED", -- Bright Magenta
              -- fg = "#000000", -- Black
            },
            -- NormalFloat = { bg = "#00FFFF" }, -- Cyan for floating windows
            -- Visual = { bg = "#FFFF00" }, -- Yellow for visual selection
          },
        },
        -- specs table would also go here if used
        specs = {},
      })

      -- >>> IMPORTANT: Ensure this runs *after* the setup call <<<
      -- vim.cmd('colorscheme github_light_default')
    end,
  },
}

-- return {
--   "rose-pine/neovim",
--   name = "rose-pine",
--   config = function()
--     vim.cmd("colorscheme rose-pine")
--   end,
-- }

-- return {
--   "folke/tokyonight.nvim",
--   priority = 1000,
--   config = function()
--     local transparent = true -- set to true if you would like to enable transparency
--
--     -- local bg = "#011628"
--     -- local bg_dark = "#011423"
--     -- local bg_highlight = "#143652"
--     -- local bg_search = "#0A64AC"
--     -- local bg_visual = "#275378"
--     -- local fg = "#CBE0F0"
--     -- local fg_dark = "#B4D0E9"
--     -- local fg_gutter = "#627E97"
--     -- local border = "#547998"
--     --
--     require("tokyonight").setup({
--       style = "moon",
--       -- transparent = transparent,
--       styles = {
--         sidebars = transparent and "transparent" or "dark",
--         floats = transparent and "transparent" or "dark",
--       },
--       --   on_colors = function(colors)
--       --     colors.bg = bg
--       --     colors.bg_dark = transparent and colors.none or bg_dark
--       --     colors.bg_float = transparent and colors.none or bg_dark
--       --     colors.bg_highlight = bg_highlight
--       --     colors.bg_popup = bg_dark
--       --     colors.bg_search = bg_search
--       --     colors.bg_sidebar = transparent and colors.none or bg_dark
--       --     colors.bg_statusline = transparent and colors.none or bg_dark
--       --     colors.bg_visual = bg_visual
--       --     colors.border = border
--       --     colors.fg = fg
--       --     colors.fg_dark = fg_dark
--       --     colors.fg_float = fg
--       --     colors.fg_gutter = fg_gutter
--       --     colors.fg_sidebar = fg_dark
--       --   end,
--       -- })
--     }, vim.cmd("colorscheme tokyonight"))
--   end,
-- }
