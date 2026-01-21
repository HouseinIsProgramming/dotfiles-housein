return {
  "typed-rocks/ts-worksheet-neovim",
  cond = not vim.g.is_vscode,
  opts = {
    severity = vim.diagnostic.severity.WARN,
  },
  config = function(_, opts)
    require("tsw").setup(opts)
  end,
}
