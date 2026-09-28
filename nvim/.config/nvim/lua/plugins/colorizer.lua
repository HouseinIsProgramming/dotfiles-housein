return {
  "norcalli/nvim-colorizer.lua",
  cond = not vim.g.is_vscode,
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    require("colorizer").setup()
  end,
}
