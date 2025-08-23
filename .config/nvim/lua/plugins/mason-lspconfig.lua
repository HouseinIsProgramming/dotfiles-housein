return {
  "mason-org/mason-lspconfig.nvim",
  dependencies = {
    "mason.nvim",
    "nvim-lspconfig",
  },
  opts = {
    ensure_installed = {
      -- Lua
      "lua_ls",
      
      -- Web Development
      "ts_ls",
      "html",
      "cssls",
      "jsonls",
      "eslint",
      "tailwindcss",
      "emmet_ls",
      
      -- Other Languages
      "taplo", -- TOML
      "marksman", -- Markdown
    },
  },
}