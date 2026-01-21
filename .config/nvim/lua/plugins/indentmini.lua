return {
  "nvimdev/indentmini.nvim",
  cond = not vim.g.is_vscode,
  event = "BufEnter",
  config = function()
    require("indentmini").setup()
    vim.cmd("highlight IndentLine guifg=#404040")
    vim.cmd("highlight IndentLineCurrent guifg=#737373")
  end,
}
