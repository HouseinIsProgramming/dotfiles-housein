return {
  "echasnovski/mini.splitjoin",
  keys = {
    { "gS", "<cmd>lua require('mini.splitjoin').toggle()<cr>", desc = "Toggle split/join" },
  },
  config = function()
    require("mini.splitjoin").setup({
      mappings = {
        toggle = 'gS',
        split = '',
        join = '',
      },
    })
  end,
}
