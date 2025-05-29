return {
  "olrtg/nvim-emmet",
  enable = false,
  event = "BufRead",
  config = function()
    vim.keymap.set({ "n", "v" }, "<leader>lw", require("nvim-emmet").wrap_with_abbreviation)
  end,
}
