-- Save and quit current file quicker

vim.keymap.set("n", "<leader>qe", ":e!<CR>", { desc = "Open from disk" })
vim.keymap.set("n", "<leader>qw", ":w<CR>", { desc = "Save" })
vim.keymap.set("n", "<leader>qq", ":bd<CR>", { desc = "Quit" })
vim.keymap.set("n", "<leader>qa", ":qa<CR>", { desc = "Quit all" })
vim.keymap.set("n", "<leader>qo", ":%bd|e#<CR>", { desc = "Quit other buffers" })

vim.keymap.set("n", "<CR>", "<CR><Cmd>cclose<CR>", { noremap = true, silent = true })

-- Quickfix list
vim.keymap.set("n", "<leader>xx", function()
	local qf_exists = false
	for _, win in pairs(vim.fn.getwininfo()) do
		if win.quickfix == 1 then
			qf_exists = true
			break
		end
	end
	if qf_exists then
		vim.cmd("cclose")
	else
		vim.cmd("copen")
	end
end, { desc = "Quickfix: Toggle" })
vim.keymap.set("n", "<leader>xn", "<Cmd>cnext<CR>zz", { desc = "Quickfix: Next" })
vim.keymap.set("n", "<leader>xp", "<Cmd>cprev<CR>zz", { desc = "Quickfix: Previous" })
vim.keymap.set("n", "<leader>gm", ":Gitsigns change_base ", { desc = "Gitsigns: Change base" })
vim.keymap.set("n", "<leader>xg", function()
	local files = vim.fn.systemlist("gh pr diff --name-only")
	if vim.v.shell_error ~= 0 then
		vim.notify("No PR found or gh error", vim.log.levels.WARN)
		return
	end
	local qf_list = {}
	for _, file in ipairs(files) do
		if file ~= "" then
			table.insert(qf_list, { filename = file, lnum = 1 })
		end
	end
	vim.fn.setqflist(qf_list)
	vim.cmd("copen")
end, { desc = "Quickfix: PR changed files" })

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
vim.keymap.set("n", "<leader><Tab>", "<C-^>", { desc = "Buffer: Alternate" })

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

-- Cmd+S to save, Cmd+W to close buffer (requires terminal passthrough)
vim.keymap.set("n", "<D-s>", "<Cmd>w<CR>", { desc = "Save" })
vim.keymap.set("i", "<D-s>", "<Cmd>w<CR>", { desc = "Save" })
vim.keymap.set("n", "<D-w>", "<Cmd>bd<CR>", { desc = "Close buffer" })

vim.keymap.set("n", "<C-k>", ":")

vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
vim.keymap.set("t", "<C-a>", "<C-a>", { noremap = true, desc = "Pass Ctrl-A to terminal (tmux prefix)" })

-- Window navigation from terminal mode
vim.keymap.set("t", "<C-w>h", "<C-\\><C-n><C-w>h", { desc = "Window: left" })
vim.keymap.set("t", "<C-w>j", "<C-\\><C-n><C-w>j", { desc = "Window: down" })
vim.keymap.set("t", "<C-w>k", "<C-\\><C-n><C-w>k", { desc = "Window: up" })
vim.keymap.set("t", "<C-w>l", "<C-\\><C-n><C-w>l", { desc = "Window: right" })
vim.keymap.set("t", "<C-w><C-w>", "<C-\\><C-n><C-w><C-w>", { desc = "Window: next" })

vim.keymap.set("n", "<leader>tn", "<Cmd>tabNext<CR>", {
	desc = "Next tab",
	noremap = true,
})

-- if not vim.g.is_vscode then
-- 	vim.keymap.set({ "v" }, "J", function()
-- 		require("mini.move").move_selection("down")
-- 		vim.cmd("normal! =gv") -- Re-select then reindent
-- 	end, { silent = true, desc = "Move selection down and reindent" })
--
-- 	-- Map Shift+K to move selected lines UP and then reindent
-- 	vim.keymap.set({ "v" }, "K", function()
-- 		require("mini.move").move_selection("up")
-- 		vim.cmd("normal! =gv") -- Re-select then reindent
-- 	end, { silent = true, desc = "Move selection up and reindent" })
-- end

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

	-- Use VSCode's undo/redo (prevents file mutation issue)
	vim.keymap.set("n", "u", function()
		vscode.call("undo")
	end)
	vim.keymap.set("n", "<C-r>", function()
		vscode.call("redo")
	end)

	-- File actions
	vim.keymap.set("n", "<leader>qe", function()
		vscode.call("workbench.action.files.revert")
	end)

	-- File navigation
	vim.keymap.set("n", "<leader>ff", function()
		vscode.call("workbench.action.quickOpen")
	end)
	vim.keymap.set("n", "<leader>fg", function()
		vscode.call("workbench.action.findInFiles")
	end)
	vim.keymap.set("n", "<leader>e", function()
		vscode.call("workbench.view.explorer")
	end)

	-- LSP actions (mapped to VSCode)
	-- Test: C-g should show hover (visible feedback)
	vim.keymap.set("i", "<C-g>", function()
		vscode.notify("editor.action.showHover")
	end)
	vim.keymap.set({ "n", "i" }, "<C-s>", function()
		vscode.notify("editor.action.triggerParameterHints")
	end)
	vim.keymap.set("n", "gd", function()
		vscode.call("editor.action.revealDefinition")
	end)
	vim.keymap.set("n", "gr", function()
		vscode.call("editor.action.goToReferences")
	end)
	vim.keymap.set("n", "K", function()
		vscode.call("editor.action.showHover")
	end)
	vim.keymap.set("n", "<leader>ca", function()
		vscode.call("editor.action.quickFix")
	end)
	vim.keymap.set("n", "gra", function()
		vscode.call("editor.action.quickFix")
	end)
	vim.keymap.set("n", "<leader>ls", function()
		vscode.call("editor.action.sourceAction")
	end)
	vim.keymap.set("n", "<leader>rn", function()
		vscode.call("editor.action.rename")
	end)

	-- Window management
	vim.keymap.set("n", "<C-h>", function()
		vscode.call("workbench.action.focusLeftGroup")
	end)
	vim.keymap.set("n", "<C-l>", function()
		vscode.call("workbench.action.focusRightGroup")
	end)

	-- Save/quit
	vim.keymap.set("n", "<leader>qw", function()
		vscode.call("workbench.action.files.save")
	end)
	vim.keymap.set("n", "<leader>qq", function()
		vscode.call("workbench.action.closeActiveEditor")
	end)
	vim.keymap.set("n", "<leader>qa", function()
		vscode.call("workbench.action.closeAllEditors")
	end)
	vim.keymap.set("n", "<leader>qo", function()
		vscode.call("workbench.action.closeOtherEditors")
	end)

	-- Format
	vim.keymap.set("n", "<leader>lf", function()
		vscode.call("editor.action.formatDocument")
	end)

	-- Pickers
	vim.keymap.set("n", "<leader>fb", function()
		vscode.call("workbench.action.showAllEditors")
	end)
	vim.keymap.set("n", "<leader>fo", function()
		vscode.call("workbench.action.openRecent")
	end)
	vim.keymap.set("n", "<leader>fs", function()
		vscode.call("workbench.action.gotoSymbol")
	end)
	vim.keymap.set("n", "<leader>fS", function()
		vscode.call("workbench.action.showAllSymbols")
	end)
	vim.keymap.set("n", "<leader>fd", function()
		vscode.call("workbench.actions.view.problems")
	end)
	vim.keymap.set("n", "<leader>gs", function()
		vscode.call("workbench.view.scm")
	end)

	-- Harpoon
	vim.keymap.set("n", "<leader>m", function()
		vscode.call("vscode-harpoon.addEditor")
	end)
	vim.keymap.set("n", "<leader>h", function()
		vscode.call("vscode-harpoon.editorQuickPick")
	end)
	for i = 1, 9 do
		vim.keymap.set("n", "<leader>" .. i, function()
			vscode.call("vscode-harpoon.gotoEditor" .. i)
		end)
	end

	-- Git hunks
	vim.keymap.set("n", "]h", function()
		vscode.call("workbench.action.editor.nextChange")
	end)
	vim.keymap.set("n", "[h", function()
		vscode.call("workbench.action.editor.previousChange")
	end)
	vim.keymap.set("n", "do", function()
		vscode.call("editor.action.dirtydiff.next")
	end)
end
