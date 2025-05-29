return {
  "supermaven-inc/supermaven-nvim",
  event = "InsertEnter",
  config = function()
    require("supermaven-nvim").setup {
      keymaps = {
        accept_suggestion = "<C-e>",
        clear_suggestion = "<C-;>",
        next_suggestion = "<C-x>",
        accept_word = "<C-j>",
      },
    }
    vim.cmd "SupermavenStop"
  end,
}
