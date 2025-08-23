return {
  "mason-org/mason.nvim",
  cmd = "Mason",
  build = ":MasonUpdate",
  opts = {
    ensure_installed = {
      "lua-language-server",
      "stylua",
    },
  },
}