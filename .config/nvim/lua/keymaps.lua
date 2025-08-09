vim.keymap.set("n", "<leader>ff", ":FzfLua files<CR>")
vim.keymap.set("n", "<leader>fg", ":FzfLua grep<CR>")
vim.keymap.set("n", "<leader>fr", ":FzfLua lsp_references<CR>")
vim.keymap.set("n", "<leader>fb", ":FzfLua buffers<CR>")
vim.keymap.set("n", "<leader>fo", ":FzfLua oldfiles<CR>")
vim.keymap.set("n", "<leader>fi", ":FzfLua lsp_implementations<CR>")
vim.keymap.set("n", "<leader>fs", ":FzfLua lsp_document_symbols<CR>")
vim.keymap.set("n", "<leader>fc", ":FzfLua lsp_code_actions<CR>")
vim.keymap.set("n", "<leader>fh", ":Pick help<CR>")
vim.keymap.set("n", "<leader>i", ":Yazi<CR>")
vim.keymap.set("n", "<leader>cf", vim.lsp.buf.format)
vim.keymap.set("i", "<C-f>", "<Right>", { noremap = true, silent = true })

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
