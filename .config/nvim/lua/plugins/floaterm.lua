return {
  "voldikss/vim-floaterm",
  lazy = false,
  config = function()
    -- Floaterm settings
    vim.g.floaterm_width = 0.9
    vim.g.floaterm_height = 0.9
    vim.g.floaterm_position = "center"
    -- vim.g.floaterm_borderchars = "─│─│╭╮╯╰"
    vim.g.floaterm_title = "Terminal ($1|$2)"
    vim.g.floaterm_autoclose = 1 -- Hide terminal when process exits
    vim.g.floaterm_opener = "edit"

    -- Custom keybindings using leader+t (should work reliably)
    vim.keymap.set("n", "<leader>j", "<cmd>FloatermToggle<CR>", { silent = true })
    vim.keymap.set("t", "<leader>j", "<C-\\><C-n><cmd>FloatermToggle<CR>", { silent = true })
    vim.keymap.set("i", "<leader>j", "<cmd>FloatermToggle<CR>", { silent = true })

    -- Additional terminal mode bindings for better control
    vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { silent = true })
  end,
}
