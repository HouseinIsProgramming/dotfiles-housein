-- Zig ftplugin configuration
-- This file is automatically loaded when a Zig buffer is opened

local function RunZigSmart()
	local build_zig = vim.fn.getcwd() .. "/build.zig"
	if vim.fn.filereadable(build_zig) == 1 then
		vim.cmd("vsplit term://zig build run")
	else
		vim.cmd("vsplit term://zig run " .. vim.fn.expand("%"))
	end
	vim.cmd("tnoremap <buffer> <C-c> exit<CR>")
	vim.cmd("startinsert")
end

local function RunZigTest()
	vim.cmd("vsplit term://zig test " .. vim.fn.expand("%"))
	vim.cmd("tnoremap <buffer> <C-c> exit<CR>")
	vim.cmd("startinsert")
end

-- Zig-specific keymaps
local opts = { buffer = true, silent = true }

-- Zig build run current file/project
vim.keymap.set("n", "<leader>kr", RunZigSmart, vim.tbl_extend("force", opts, { desc = "Zig build run" }))

-- Zig test current file
vim.keymap.set("n", "<leader>kt", RunZigTest, vim.tbl_extend("force", opts, { desc = "Zig test current file" }))
