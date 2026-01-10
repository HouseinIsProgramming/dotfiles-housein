local function RunUvFile()
	vim.cmd("split term://uv run " .. vim.fn.expand("%"))
	vim.cmd("startinsert")
end

local opts = { buffer = true, silent = true }

vim.keymap.set("n", "<leader>kr", RunUvFile, vim.tbl_extend("force", opts, { desc = "Run with uv" }))
vim.keymap.set("n", "<leader>kt", ":split term://uv run pytest<CR>:startinsert<CR>", vim.tbl_extend("force", opts, { desc = "Run pytest" }))
vim.keymap.set("n", "<leader>ki", ":split term://uv sync<CR>:startinsert<CR>", vim.tbl_extend("force", opts, { desc = "uv sync" }))
vim.keymap.set("n", "<leader>ka", ":split term://uv add ", vim.tbl_extend("force", opts, { desc = "uv add..." }))
vim.keymap.set("n", "<leader>kv", ":split term://uv venv<CR>:startinsert<CR>", vim.tbl_extend("force", opts, { desc = "uv venv" }))

vim.opt_local.tabstop = 4
vim.opt_local.shiftwidth = 4
vim.opt_local.expandtab = true
