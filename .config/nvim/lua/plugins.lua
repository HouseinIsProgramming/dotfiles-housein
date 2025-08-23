return {
  -- LSP Configuration
  { "neovim/nvim-lspconfig" },
  { "mason-org/mason.nvim" },
  { "mason-org/mason-lspconfig.nvim" },
  { "WhoIsSethDaniel/mason-tool-installer.nvim" },

  -- Lazydev for better Lua development
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },

  -- Completion
  { "saghen/blink.cmp" },

  -- Dependencies
  { "nvim-lua/plenary.nvim" },

  -- UI and Navigation
  { "echasnovski/mini.pick" },
  { "ibhagwan/fzf-lua" },
  { "mikavilpas/yazi.nvim" },

  -- Treesitter
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },

  -- Snippets
  { "L3MON4D3/LuaSnip" },
  { "rafamadriz/friendly-snippets" },

  -- Formatting
  { "stevearc/conform.nvim" },

  -- Themes
  { "folke/tokyonight.nvim" },

  -- Language specific
  { "glebzlat/arduino-nvim" },
  { "davidmh/mdx.nvim" },

  -- Text objects and editing
  { "echasnovski/mini.ai" },
  { "windwp/nvim-autopairs" },

  -- AI completion
  { "supermaven-inc/supermaven-nvim" },

  -- Folding
  { "kevinhwang91/promise-async" },
  { "kevinhwang91/nvim-ufo" },

  -- Utilities
  { "jmattaa/regedit.vim" },
  { "nvimdev/indentmini.nvim" },
  { "jiaoshijie/undotree" },

  -- Markdown rendering
  { "MeanderingProgrammer/render-markdown.nvim" },

  -- Mini suite
  { "echasnovski/mini.nvim" },
}
