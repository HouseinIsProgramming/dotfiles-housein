return {
  "mason-org/mason-lspconfig.nvim",
  dependencies = {
    "mason.nvim",
    "nvim-lspconfig",
  },
  opts = {
    ensure_installed = {
      "lua_ls",
    },
  },
}