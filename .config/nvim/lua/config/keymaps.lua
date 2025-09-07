-- Save and quit current file quicker

vim.keymap.set("n", "<leader>qe", ":e!<CR>", { desc = "Open from disk" })
vim.keymap.set("n", "<leader>ww", ":w<CR>", { desc = "Save" })
vim.keymap.set("n", "<leader>wu", "<cmd>lua require('undotree').toggle()<cr>", { desc = "Undo tree" })
vim.keymap.set("n", "<leader>qq", ":bd<CR>", { desc = "Quit" })
vim.keymap.set("n", "<leader>qa", ":qa<CR>", { desc = "Quit all" })

-- Little one from Primeagen to mass replace string in a file
vim.keymap.set("n", "<leader>sr", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { silent = false })

vim.keymap.set("n", "<ESC>", ":nohlsearch<CR>", { noremap = true, silent = true })

vim.keymap.set("n", "yag", ":%y<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "vag", "ggVG", { noremap = true, silent = true })

-- Navigate through buffers
vim.keymap.set("n", "<Tab>", ":bnext<CR>", { silent = false })
vim.keymap.set("n", "<S-Tab>", ":bprevious<CR>", { silent = false })

-- Center buffer when navigating up and down
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "<C-d>", "<C-d>zz")

-- Center buffer when progressing through search results
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- Paste without replacing paste with what you are highlighted over
vim.keymap.set("n", "<leader>p", '"_dP')
vim.keymap.set("n", "<S-p>", '"_dP')

-- Configure c command to put deleted text into c register
vim.keymap.set("n", "c", '"cc', { noremap = true })
vim.keymap.set("v", "c", '"cc', { noremap = true })
-- Configure d command to put deleted text into d register
vim.keymap.set("n", "<S-d>", '"dd', { noremap = true })
vim.keymap.set("v", "<S-d>", '"dd', { noremap = true })

vim.keymap.set("i", "<C-f>", "<Right>", { noremap = true, silent = true })
vim.keymap.set("i", "<C-b>", "<Left>", { noremap = true, silent = true })

vim.keymap.set("n", "<C-k>", ":")

vim.keymap.set("t", "<C-c>", [[<C-\><C-n>]])

vim.keymap.set({ "v" }, "J", function()
	require("mini.move").move_selection("down")
	vim.cmd("normal! =gv") -- Re-select then reindent
end, { silent = true, desc = "Move selection down and reindent" })

-- Map Shift+K to move selected lines UP and then reindent
vim.keymap.set({ "v" }, "K", function()
	require("mini.move").move_selection("up")
	vim.cmd("normal! =gv") -- Re-select then reindent
end, { silent = true, desc = "Move selection up and reindent" })

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
