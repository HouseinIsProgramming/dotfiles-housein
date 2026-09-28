return {
  "dmmulroy/ts-error-translator.nvim",
  cond = not vim.g.is_vscode,
  config = function()
    require("ts-error-translator").setup()
  end,
}
