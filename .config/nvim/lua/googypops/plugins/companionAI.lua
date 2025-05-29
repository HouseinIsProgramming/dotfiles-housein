return {
  "olimorris/codecompanion.nvim",
  enabled = false,
  event = "BufReadPost",

  opts = {},

  config = function(_, opts)
    require("codecompanion").setup(opts)

    vim.keymap.set({ "n", "v" }, "<leader>ac", "<cmd>CodeCompanionActions<cr>", { noremap = true, silent = true })
    vim.keymap.set({ "n", "v" }, "<leader>aa", "<cmd>CodeCompanionChat Toggle<cr>", { noremap = true, silent = true })
    vim.keymap.set(
      { "n", "v" },
      "<LocalLeader>a",
      "<cmd>CodeCompanionChat Toggle<cr>",
      { noremap = true, silent = true }
    )
    vim.keymap.set("v", "ga", "<cmd>CodeCompanionChat Add<cr>", { noremap = true, silent = true })
    vim.keymap.set("v", "<leader>al", ":'<,'>CodeCompanion ", { noremap = true, silent = false })
    vim.keymap.set("n", "<leader>al", ":CodeCompanion /buffer", { noremap = true, silent = false })

    require("plugins.utilitiesMods.fidget"):init()
  end,

  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    "j-hui/fidget.nvim",
  },
}
