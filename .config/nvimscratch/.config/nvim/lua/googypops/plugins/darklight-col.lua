return {
  {
    "nvim-tree/nvim-web-devicons",
    config = function()
      require("nvim-web-devicons").setup({})
    end,
  },
  {
    "f-person/auto-dark-mode.nvim",
    lazy = false,
    priority = 999,
    -- event = "VeryLazy",
    dependencies = {
      "nvim-tree/nvim-web-devicons", -- ensure it's loaded first
    },
    opts = {
      set_dark_mode = function()
        vim.cmd.set("background=dark")
        vim.cmd.colorscheme("catppuccin")
      end,
      set_light_mode = function()
        vim.cmd.set("background=light")
        vim.cmd.colorscheme("github_light_default")
      end,
      -- update_interval = 3000,
      fallback = "dark",
    },
  },
}

-- return {
--   'eliseshaffer/darklight.nvim',
--   lazy = false,
--   opts = {
--     mode = 'callback', -- so we can run code instead of colorscheme
--     light_mode_callback = function()
--       require('nvconfig').base46.theme = 'everforest_light'
--       require('base46').load_all_highlights()
--     end,
--     dark_mode_callback = function()
--       require('nvconfig').base46.theme = 'kanagawa'
--       require('base46').load_all_highlights()
--     end,
--   },
-- }
--
--
--
-- return {
--   'eliseshaffer/darklight.nvim',
--   lazy = false,
--   config = function()
--     require('darklight').setup {
--       mode = 'custom',
--       light_mode_callback = function()
--         require('nvconfig').base46.theme = 'everforest_light'
--         require('base46').load_all_highlights()
--         vim.notify('Switched to light mode (everforest_light)', vim.log.levels.INFO)
--       end,
--       dark_mode_callback = function()
--         require('nvconfig').base46.theme = 'everforest'
--         require('base46').load_all_highlights()
--         vim.notify('Switched to dark mode (kanagawa)', vim.log.levels.INFO)
--       end,
--     }
--   end,
-- }
--
-- return {
--   'eliseshaffer/darklight.nvim',
--   lazy = false,
--   opts = {
--     mode = 'custom', -- Sets darklight to custom mode
--     light_mode_callback = function()
--       vim.g.nvchad_theme = 'everforest_light'
--       require('nvconfig').base46.theme = 'everforest_light'
--       require('base46').load_all_highlights()
--       vim.notify('Darklight: switched to LIGHT mode (everforest_light)', vim.log.levels.INFO)
--     end,
--     dark_mode_callback = function()
--       vim.g.nvchad_theme = 'kanagawa'
--       require('nvconfig').base46.theme = 'kanagawa'
--       require('base46').load_all_highlights()
--       vim.notify('Darklight: switched to DARK mode (kanagawa)', vim.log.levels.INFO)
--     end,
--   },
-- }

-- return {
--   'SyedFasiuddin/theme-toggle-nvim',
--   enabled = false,
--   config = function()
--     require('theme-toggle-nvim').setup {
--       colorscheme = {
--         light = function()
--           require('nvconfig').base46.theme = 'everforest_light'
--           require('base46').load_all_highlights()
--         end,
--         dark = function()
--           require('nvconfig').base46.theme = 'kanagawa-wave'
--           require('base46').load_all_highlights()
--         end,
--       },
--     }
--   end,
-- }
-- --
-- return {
--
--   'SyedFasiuddin/theme-toggle-nvim',
--   enabled = false,
--   config = function()
--     require('theme-toggle-nvim').setup {
--       colorscheme = {
--         light = 'hybrid_material',
--         dark = 'kanagawa-wave',
--       },
--     }
--   end,
-- }
--
-- return {
--
--   'eliseshaffer/darklight.nvim',
--   opts = function()
--     -- Add 'return' here
--     return {
--       mode = 'colorscheme', -- Sets darklight to colorscheme mode
--       light_mode_colorscheme = 'rusticated', -- Sets the colorscheme to use for light mode
--       dark_mode_colorscheme = 'kanagawa-wave', -- Sets the colorscheme to use for dark mode
--     }
--   end,
-- }
