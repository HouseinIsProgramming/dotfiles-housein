return {
  "mason-org/mason.nvim",
  cmd = "Mason",
  build = ":MasonUpdate",
  opts = {
    -- Mason core settings
    -- LSP servers are managed by mason-lspconfig.lua
    -- Tools are managed by mason-tool-installer.lua
  },
}
