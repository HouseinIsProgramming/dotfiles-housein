return {
  "nvim-telescope/telescope.nvim",
  -- branch = "0.1.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    "nvim-tree/nvim-web-devicons",
    "folke/todo-comments.nvim",
  },
  config = function()
    local telescope = require("telescope")
    local actions = require("telescope.actions")
    local transform_mod = require("telescope.actions.mt").transform_mod

    -- or create your custom action
    local custom_actions = transform_mod({
      open_trouble_qflist = function(prompt_bufnr)
        -- trouble.toggle("quickfix")
      end,
    })

    -- Appearance settings
    local h_pct = 0.90
    local w_pct = 0.80
    local w_limit = 75
    local standard_setup = {
      borderchars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
      preview = { hide_on_startup = false },
      layout_strategy = "horizontal",

      layout_config = {

        horizontal = {
          prompt_position = "top",
          preview_width = 0.55,
        },
        vertical = {
          mirror = true,
          prompt_position = "top",
          width = function(_, cols, _)
            return math.min(math.floor(w_pct * cols), w_limit)
          end,
          height = function(_, _, rows)
            return math.floor(rows * h_pct)
          end,
          preview_cutoff = 10,
          preview_height = 0.4,
        },
      },
    }

    telescope.setup({
      defaults = vim.tbl_extend("error", standard_setup, {
        sorting_strategy = "ascending",
        path_display = { "smart" },
        mappings = {
          i = {
            ["<C-k>"] = actions.move_selection_previous, -- move to prev result
            ["<C-j>"] = actions.move_selection_next, -- move to next result
            ["<C-o>"] = require("telescope.actions.layout").toggle_preview,
          },
          n = {
            ["o"] = require("telescope.actions.layout").toggle_preview,
            ["<C-c>"] = actions.close,
          },
        },
      }),
      pickers = {
        find_files = {
          theme = "ivy",
          find_command = {
            "fd",
            "--type",
            "f",
            "-H",
            "--strip-cwd-prefix",
          },
        },
        live_grep = { theme = "ivy" },
        buffers = { theme = "ivy" },
      },
      extensions = {
        -- Extend functionality (preserve your existing extensions and add custom appearance)
      },
    })

    telescope.load_extension("fzf")

    -- set keymaps
    local builtin = require("telescope.builtin")
    vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "[F]ind [H]elp" })
    vim.keymap.set("n", "<leader>fk", builtin.keymaps, { desc = "[F]ind [K]eymaps" })
    vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "[F]ind [F]iles" })
    vim.keymap.set("n", "<leader>fs", builtin.builtin, { desc = "[F]ind [S]elect Telescope" })
    vim.keymap.set("n", "<leader>fw", builtin.grep_string, { desc = "[F]ind current [W]ord" })
    vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "[F]ind by [G]rep" })
    vim.keymap.set("n", "<leader>fd", builtin.diagnostics, { desc = "[F]ind [D]iagnostics" })
    vim.keymap.set("n", "<leader>fr", builtin.resume, { desc = "[F]ind [R]esume" })
    vim.keymap.set("n", "<leader>fo", builtin.oldfiles, { desc = "[F]ind Recent Files" })
    vim.keymap.set("n", "<leader><leader>", builtin.buffers, { desc = "[ ] Find existing buffers" })
    vim.keymap.set("n", "<leader>fn", function()
      builtin.find_files({ cwd = vim.fn.stdpath("config") })
    end, { desc = "[F]ind [N]eovim files" })
  end,
}
