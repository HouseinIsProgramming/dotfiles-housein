local function RunUvFile()
	vim.cmd("update")
	vim.cmd("split term://uv run " .. vim.fn.expand("%"))
	vim.cmd("startinsert")
end

local function RunCommand(cmd, start_insert)
	vim.cmd("update")
	vim.cmd("split term://" .. cmd)
	if start_insert then
		vim.cmd("startinsert")
	end
end

local opts = { buffer = true, silent = true }
vim.keymap.set("n", "<leader>kr", RunUvFile, vim.tbl_extend("force", opts, { desc = "Run with uv" }))
vim.keymap.set("n", "<leader>kt", function()
	RunCommand("uv run pytest", true)
end, vim.tbl_extend("force", opts, { desc = "Run pytest" }))
vim.keymap.set("n", "<leader>ki", function()
	RunCommand("uv sync", true)
end, vim.tbl_extend("force", opts, { desc = "uv sync" }))
vim.keymap.set("n", "<leader>ka", function()
	RunCommand("uv add ", false)
end, vim.tbl_extend("force", opts, { desc = "uv add..." }))
vim.keymap.set("n", "<leader>kv", function()
	RunCommand("uv venv", true)
end, vim.tbl_extend("force", opts, { desc = "uv venv" }))

vim.opt_local.tabstop = 4
vim.opt_local.shiftwidth = 4
vim.opt_local.expandtab = true
