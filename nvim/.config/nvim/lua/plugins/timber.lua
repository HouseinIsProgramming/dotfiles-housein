return {
  "Goose97/timber.nvim",
  cond = not vim.g.is_vscode,
  version = "*", -- Use for stability; omit to use `main` branch for the latest features
  event = "VeryLazy",
  config = function()
    require("timber").setup({
      -- Configuration here, or leave empty to use defaults
    })
  end,
}
