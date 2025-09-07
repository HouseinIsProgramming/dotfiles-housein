return {
  "WhoIsSethDaniel/mason-tool-installer.nvim",
  dependencies = {
    "mason.nvim",
  },
  opts = {
    ensure_installed = {
      -- Lua Tools
      "stylua",
      "luacheck",

      -- Formatters
      "prettier",
      "prettierd",
      "rustywind",

      -- Other Tools
      "glow", -- Markdown viewer
    },
  },
}

