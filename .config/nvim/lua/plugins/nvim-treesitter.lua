return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter.configs").setup({
      ensure_installed = {
        -- Base
        "lua",
        "vim",
        "vimdoc",
        "query",
        -- Web Development
        "html",
        "css",
        "scss",
        "javascript",
        "typescript",
        "tsx",
        -- "jsx",
        "json",
        "jsonc",
        "yaml",
        "toml",
        "markdown",

        "markdown_inline",
        -- Other useful parsers
        "bash",
        "dockerfile",
        "gitignore",
        "regex",
      },
      auto_install = true,
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },
      indent = {
        enable = true,
      },
      incremental_selection = {
        enable = true,
        keymaps = {
          node_incremental = "<C-o>",
          scope_incremental = false,
          node_decremental = "<C-i>",
        },
      },

      textobjects = {
        move = {
          enable = true,
          set_jumps = true, -- whether to set jumps in the jumplist
          goto_next_start = {
            ["]m"] = "@function.outer",
            ["]f"] = "@function.outer",
            ["]]"] = { query = "@class.outer", desc = "Next class start" },
          },
          goto_previous_start = {
            ["[m"] = "@function.outer",
            ["[f"] = "@function.outer",
            ["[["] = { query = "@class.outer", desc = "Previous class start" },
          },
        },
        select = {
          enable = true,
          lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
          keymaps = {
            -- You can use the capture groups defined in textobjects.scm
            ["af"] = "@function.outer",
            ["if"] = "@function.inner",
            ["ac"] = "@class.outer",
            ["ic"] = "@class.inner",
          },
        },
      },
    })
  end,
}
