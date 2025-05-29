return {
  "folke/todo-comments.nvim",
  lazy = true,
  event = { "BufRead", "BufNewFile" },
  dependencies = { "nvim-lua/plenary.nvim" },
  opts = {
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below

    vim.keymap.set("n", "<leader>fq", "<CMD>TodoTelescope<CR>", { desc = "Todo list" }),
  },
}
