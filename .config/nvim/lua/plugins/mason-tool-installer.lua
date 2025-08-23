return {
  "WhoIsSethDaniel/mason-tool-installer.nvim",
  dependencies = {
    "mason.nvim",
  },
  opts = {
    ensure_installed = {
      "lua-language-server",
      "stylua",
    },
  },
}