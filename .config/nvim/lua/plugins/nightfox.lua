return {
  "EdenEast/nightfox.nvim",
  lazy = false,   -- make sure we load this during startup if it is your main colorscheme
  priority = 1000, -- make sure to load this before all the other plugins
  config = function()
    require("nightfox").setup({
      options = {
        styles = {
          -- comments = "italic",
          keywords = "bold",
          types = "italic,bold",
        },
      },
    })
    vim.cmd("colorscheme nordfox") -- Change "nightfox" to "nordfox" here
    --   local function set_blink_highlights()
    --     vim.api.nvim_set_hl(0, "BlinkCmpMenu", { fg = "NONE", bg = "#18181B" })
    --     vim.api.nvim_set_hl(0, "BlinkCmpMenuBorder", { fg = "NONE", bg = "#27272A" })
    --   end
    --
    --   vim.api.nvim_create_autocmd("ColorScheme", {
    --     pattern = "*",
    --     callback = set_blink_highlights,
    --     desc = "Set custom BlinkCmp highlights after colorscheme loads",
    --   })
  end,
}
