return {
  "ThePrimeagen/refactoring.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  lazy = false,
  opts = {},
  config = function() require("refactoring").setup({}) end,
  vim.keymap.set({ "n", "x" }, "<leader>cr", function() require("refactoring").select_refactor() end),
  vim.keymap.set({ "x", "n" }, "<leader>cv", function() require("refactoring").debug.print_var() end),
}
