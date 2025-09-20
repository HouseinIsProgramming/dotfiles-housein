return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
    bigfile = { enabled = false },
    dashboard = {
      enabled = true,
      sections = {
        { icon = " ", title = "Keymaps", section = "keys", indent = 2, padding = 1 },
        { icon = " ", title = "Recent Files", section = "recent_files", cwd = true, indent = 2, padding = 1 },
        { icon = " ", title = "Projects", section = "projects", indent = 2, padding = 1 },
      },
    },
    -- explorer = { enabled = false },
    -- indent = { enabled = false },
    -- input = { enabled = false },
    picker = { enabled = true, ui_select = true },
    -- notifier = { enabled = false },
    -- quickfile = { enabled = false },
    -- scope = { enabled = false },
    -- scroll = { enabled = false },
    -- statuscolumn = { enabled = false },
    -- words = { enabled = false },
  },
  keys = {

    { "<leader>ff", function() Snacks.picker.smart() end,                                   desc = "Find Files" },
    { "<leader>fc", function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end, desc = "Find Config File" },
    { "<leader>fb", function() Snacks.picker.buffers() end,                                 desc = "Find Buffers" },
    { "<leader>fm", function() Snacks.picker.marks() end,                                   desc = "Find Marks" },
    { "<leader>fo", function() Snacks.picker.recent() end,                                  desc = "Find Old Files" },
    { "<leader>fg", function() Snacks.picker.grep() end,                                    desc = "Find Live Grep" },
    { "<leader>fr", function() Snacks.picker.registers() end,                               desc = "Find Registers" },
    --git
    { "<leader>fG", function() Snacks.picker.git_files() end,                               desc = "Find Git Files" },
    { "<leader>gs", function() Snacks.picker.git_status() end,                              desc = "Git Status" },
    { "<leader>gd", function() Snacks.picker.git_diff() end,                                desc = "Git Diff (Hunks)" },
    -- diagnostics
    { "<leader>fd", function() Snacks.picker.diagnostics() end,                             desc = "Diagnostics" },
    -- undo
    { "<leader>fu", function() Snacks.picker.undo() end,                                    desc = "Undo History" },
    -- fun
    { "<leader>uC", function() Snacks.picker.colorschemes() end,                            desc = "Colorschemes" },
    -- LSP
    { "gd",         function() Snacks.picker.lsp_definitions() end,                         desc = "Goto Definition" },
    { "gD",         function() Snacks.picker.lsp_declarations() end,                        desc = "Goto Declaration" },
    { "grr",        function() Snacks.picker.lsp_references() end,                          nowait = true,                  desc = "References" },
    { "gri",        function() Snacks.picker.lsp_implementations() end,                     desc = "Goto Implementation" },
    { "grt",        function() Snacks.picker.lsp_type_definitions() end,                    desc = "Goto T[y]pe Definition" },
    { "<leader>fs", function() Snacks.picker.lsp_symbols() end,                             desc = "LSP Symbols" },
    { "<leader>fS", function() Snacks.picker.lsp_workspace_symbols() end,                   desc = "LSP Workspace Symbols" },


  },
  {
    "folke/todo-comments.nvim",
    optional = true,
    keys = {
      { "<leader>ft", function() Snacks.picker.todo_comments() end,                                          desc = "Todo" },
      { "<leader>fT", function() Snacks.picker.todo_comments({ keywords = { "TODO", "FIX", "FIXME" } }) end, desc = "Todo/Fix/Fixme" },
    },
  }
}
