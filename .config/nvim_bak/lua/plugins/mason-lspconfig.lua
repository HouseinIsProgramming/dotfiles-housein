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

      -- Web Development (TypeScript/JavaScript)
      "vtsls", -- Modern TypeScript LSP (replaces ts_ls)
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
    -- Disable automatic installation for servers not in ensure_installed
    automatic_installation = false,
  },
}
