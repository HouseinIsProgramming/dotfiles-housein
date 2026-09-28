local function RunMake(target)
	vim.cmd("update")
	local cmd = target and ("make " .. target) or "make"
	vim.cmd("vsplit term://" .. cmd)
	vim.cmd("tnoremap <buffer> <C-c> exit<CR>")
	vim.cmd("startinsert")
end

local opts = { buffer = true, silent = true }

vim.keymap.set("n", "<leader>kr", function()
	RunMake("run")
end, vim.tbl_extend("force", opts, { desc = "make run" }))
vim.keymap.set("n", "<leader>kb", function()
	RunMake("build")
end, vim.tbl_extend("force", opts, { desc = "make build" }))
vim.keymap.set("n", "<leader>km", function()
	RunMake()
end, vim.tbl_extend("force", opts, { desc = "make" }))
vim.keymap.set("n", "<leader>kt", function()
	RunMake("test")
end, vim.tbl_extend("force", opts, { desc = "make test" }))
