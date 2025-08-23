return {
  "mason-org/mason.nvim",
  cmd = "Mason",
  build = ":MasonUpdate",
  opts = {
    ensure_installed = {
      -- Lua
      "lua-language-server",
      "stylua",
      "luacheck",

      -- Web Development
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

