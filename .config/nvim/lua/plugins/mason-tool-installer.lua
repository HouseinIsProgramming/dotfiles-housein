return {
  "WhoIsSethDaniel/mason-tool-installer.nvim",
  dependencies = {
    "mason.nvim",
  },
  opts = {
    ensure_installed = {
      -- Lua
      "lua-language-server",
      "stylua",
      
      -- Web Development LSP
      "typescript-language-server",
      "html-lsp",
      "css-lsp",
      "json-lsp",
      "eslint-lsp",
      "tailwindcss-language-server",
      "emmet-ls",
      
      -- Formatters
      "prettier",
      "prettierd",
      "rustywind",
      
      -- Other Languages
      "taplo", -- TOML
      "marksman", -- Markdown
    },
  },
}