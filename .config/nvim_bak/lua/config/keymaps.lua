vim.keymap.set("n", "<leader>ff", ":FzfLua files<CR>")
vim.keymap.set("n", "<leader>fg", ":FzfLua grep<CR>")
vim.keymap.set("n", "<leader>fr", ":FzfLua lsp_references<CR>")
vim.keymap.set("n", "<leader>fb", ":FzfLua buffers<CR>")
vim.keymap.set("n", "<leader>fd", ":FzfLua lsp_workspace_diagnostics<CR>")
vim.keymap.set("n", "<leader>fo", ":FzfLua oldfiles<CR>")
vim.keymap.set("n", "<leader>fi", ":FzfLua lsp_implementations<CR>")
vim.keymap.set("n", "<leader>fs", ":FzfLua lsp_document_symbols<CR>")
vim.keymap.set("n", "<leader>fS", ":FzfLua lsp_workspace_symbols<CR>")
vim.keymap.set("n", "<leader>lc", ":FzfLua lsp_code_actions<CR>")
vim.keymap.set("n", "<leader>fh", ":Pick help<CR>")

vim.keymap.set("n", "<TAB>", ":bn<CR>", { silent = true })
vim.keymap.set("n", "<S-TAB>", ":bp<CR>", { silent = true })

vim.keymap.set("n", "<leader>i", ":Yazi<CR>")

vim.keymap.set("n", "<C-k>", ":")

vim.keymap.set({ "v" }, "J", function()
  require("mini.move").move_selection("down")
  vim.cmd("normal! =gv") -- Re-select then reindent
end, { silent = true, desc = "Move selection down and reindent" })

-- Map Shift+K to move selected lines UP and then reindent
vim.keymap.set({ "v" }, "K", function()
  require("mini.move").move_selection("up")
  vim.cmd("normal! =gv") -- Re-select then reindent
end, { silent = true, desc = "Move selection up and reindent" })

vim.keymap.set("n", "<leader>qe", ":e!<CR>", { desc = "Open from disk" })
vim.keymap.set("n", "<leader>ww", ":w<CR>", { desc = "Save" })
vim.keymap.set("n", "<leader>wu", "<cmd>lua require('undotree').toggle()<cr>", { desc = "Undo tree" })
vim.keymap.set("n", "<leader>qq", ":bd<CR>", { desc = "Quit" })
vim.keymap.set("n", "<leader>qa", ":qa<CR>", { desc = "Quit all" })

vim.keymap.set("n", "<ESC>", ":nohlsearch<CR>", { noremap = true, silent = true })

vim.keymap.set("n", "yag", ":%y<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "vag", "ggVG", { noremap = true, silent = true })

vim.keymap.set("i", "<C-f>", "<Right>", { noremap = true, silent = true })
vim.keymap.set("i", "<C-b>", "<Left>", { noremap = true, silent = true })

vim.keymap.set("t", "<C-c>", [[<C-\><C-n>]])

-- Function to toggle LSP diagnostics
local diagnostics_enabled = true
local function toggle_diagnostics()
  diagnostics_enabled = not diagnostics_enabled
  vim.diagnostic.config({
    virtual_text = diagnostics_enabled, -- Toggle virtual text
    signs = diagnostics_enabled, -- Toggle signs in the gutter
    underline = diagnostics_enabled, -- Toggle underlining
  })
  if diagnostics_enabled then
    print("LSP diagnostics enabled")
  else
    print("LSP diagnostics disabled")
  end
end

-- Keybinding to toggle diagnostics
vim.keymap.set("n", "<leader>ud", toggle_diagnostics, { desc = "Toggle LSP diagnostics" })

-- Function to toggle between virtual text and virtual lines
local virtual_lines_enabled = false
local function toggle_virtual_lines()
  virtual_lines_enabled = not virtual_lines_enabled
  vim.diagnostic.config({
    virtual_text = not virtual_lines_enabled, -- Disable virtual text when virtual lines are enabled
    virtual_lines = virtual_lines_enabled, -- Enable virtual lines
    signs = true, -- Keep signs in the gutter
    underline = true, -- Keep underlining
  })
  vim.notify(virtual_lines_enabled and "Virtual lines enabled" or "Virtual text enabled", vim.log.levels.INFO)
end

-- Keybinding to toggle virtual lines
vim.keymap.set("n", "<leader>uv", toggle_virtual_lines, { desc = "Toggle virtual lines for diagnostics" })

-- Configure c command to put deleted text into c register
vim.keymap.set("n", "c", '"cc', { noremap = true })
vim.keymap.set("v", "c", '"cc', { noremap = true })

vim.keymap.set("n", "<S-d>", '"dd', { noremap = true })
vim.keymap.set("v", "<S-d>", '"dd', { noremap = true })

vim.keymap.set(
  "n",
  "<leader>lg",
  function() vim.cmd("FloatermNew --autoclose=2 lazygit") end,
  { desc = "Open Lazygit in floaterm", silent = true }
)
