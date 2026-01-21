-- Save and quit current file quicker

vim.keymap.set("n", "<leader>qe", ":e!<CR>", { desc = "Open from disk" })
vim.keymap.set("n", "<leader>qw", ":w<CR>", { desc = "Save" })
vim.keymap.set("n", "<leader>qq", ":bd<CR>", { desc = "Quit" })
vim.keymap.set("n", "<leader>qa", ":qa<CR>", { desc = "Quit all" })
vim.keymap.set("n", "<leader>qo", ":%bd|e#<CR>", { desc = "Quit other buffers" })

vim.keymap.set("n", "<CR>", "<CR><Cmd>cclose<CR>", { noremap = true, silent = true })

-- Little one from Primeagen to mass replace string in a file
vim.keymap.set("n", "<leader>sr", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { silent = false })

vim.keymap.set("n", "<ESC>", ":nohlsearch<CR>", { noremap = true, silent = true })

vim.keymap.set({ "n", "v" }, "x", '"_x', { silent = true })
vim.keymap.set({ "n", "v" }, "D", '"_d', { silent = true })
vim.keymap.set({ "n", "v" }, "P", '"_p', { silent = true })

vim.keymap.set("n", "yag", ":%y<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "vag", "ggVG", { noremap = true, silent = true })

-- auto-correct under cursor
vim.keymap.set({ "n", "v" }, "<leader>cc", "1z=")

-- Navigate through buffers
vim.keymap.set("n", "<leader><C-i>", ":bnext<CR>", { silent = false, desc = "Buffer: Next" })
vim.keymap.set("n", "<leader><C-o>", ":bprevious<CR>", { silent = false, desc = "Buffer: Previous" })

-- Center buffer when progressing through search results
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- use j and k with gj and gk to navigate between lines
vim.keymap.set("n", "j", "gj")
vim.keymap.set("n", "k", "gk")

vim.keymap.set("n", "gh", "0", { desc = "Jump: Start of line" })
vim.keymap.set("n", "gl", "$", { desc = "Jump: End of line" })

-- Paste without replacing paste with what you are highlighted over
vim.keymap.set({ "n", "v" }, "<leader>p", '"_dP')
vim.keymap.set({ "n", "v" }, "<S-p>", '"_dP')

vim.keymap.set({ "n", "v" }, "c", '"cc', { noremap = true })

vim.keymap.set({ "n", "v" }, "<S-d>", '"dd', { noremap = true })

vim.keymap.set("i", "<C-f>", "<Right>", { noremap = true, silent = true })
vim.keymap.set("i", "<C-b>", "<Left>", { noremap = true, silent = true })

-- Delete previous word in insert mode (Ctrl+Backspace)
-- Note: Most terminals send <C-H> for Ctrl+Backspace
-- Exit and re-enter insert mode to create an undo breakpoint
vim.keymap.set("i", "<C-H>", "<C-G>u<C-W>", { noremap = true, silent = true, desc = "Delete previous word" })

-- Delete to start of line in insert mode (Cmd+Backspace on macOS)
-- Exit and re-enter insert mode to create an undo breakpoint
vim.keymap.set("i", "<D-BS>", "<C-G>u<C-U>", { noremap = true, silent = true, desc = "Delete to start of line" })

vim.keymap.set("n", "<C-k>", ":")

vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

vim.keymap.set("n", "<leader>tn", "<Cmd>tabNext<CR>", {
	desc = "Next tab",
	noremap = true,
})

if not vim.g.is_vscode then
	vim.keymap.set({ "v" }, "J", function()
		require("mini.move").move_selection("down")
		vim.cmd("normal! =gv") -- Re-select then reindent
	end, { silent = true, desc = "Move selection down and reindent" })

	-- Map Shift+K to move selected lines UP and then reindent
	vim.keymap.set({ "v" }, "K", function()
		require("mini.move").move_selection("up")
		vim.cmd("normal! =gv") -- Re-select then reindent
	end, { silent = true, desc = "Move selection up and reindent" })
end

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
		virtual_text = virtual_lines_enabled and false or {
			virt_text_pos = "eol_right_align",
		},
		virtual_lines = virtual_lines_enabled,
		signs = true,
		underline = true,
		update_in_insert = false,
		severity_sort = true,
	})
	vim.notify(virtual_lines_enabled and "Virtual lines enabled" or "Virtual text enabled", vim.log.levels.INFO)
end

-- Keybinding to toggle virtual lines
vim.keymap.set("n", "<leader>uv", toggle_virtual_lines, { desc = "Toggle virtual lines for diagnostics" })

-- Toggle lsp inlay hints
vim.keymap.set("n", "<leader>uh", function()
	vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end)

-- VSCode Neovim keymaps
if vim.g.is_vscode then
	local vscode = require("vscode")

	-- File actions
	vim.keymap.set("n", "<leader>qe", function() vscode.call("workbench.action.files.revert") end)

	-- File navigation
	vim.keymap.set("n", "<leader>ff", function() vscode.call("workbench.action.quickOpen") end)
	vim.keymap.set("n", "<leader>fg", function() vscode.call("workbench.action.findInFiles") end)
	vim.keymap.set("n", "<leader>e", function() vscode.call("workbench.view.explorer") end)

	-- LSP actions (mapped to VSCode)
	vim.keymap.set("n", "gd", function() vscode.call("editor.action.revealDefinition") end)
	vim.keymap.set("n", "gr", function() vscode.call("editor.action.goToReferences") end)
	vim.keymap.set("n", "K", function() vscode.call("editor.action.showHover") end)
	vim.keymap.set("n", "<leader>ca", function() vscode.call("editor.action.quickFix") end)
	vim.keymap.set("n", "<leader>rn", function() vscode.call("editor.action.rename") end)

	-- Window management
	vim.keymap.set("n", "<C-h>", function() vscode.call("workbench.action.focusLeftGroup") end)
	vim.keymap.set("n", "<C-l>", function() vscode.call("workbench.action.focusRightGroup") end)
end
