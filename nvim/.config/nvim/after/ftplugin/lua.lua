-- Lua ftplugin configuration

vim.keymap.set("n", "<leader>kr", function()
	local cwd = vim.fn.getcwd()

	vim.cmd("write")
	vim.cmd("vsplit")
	vim.cmd("enew")
	vim.cmd("terminal love .")

	-- ensure it runs from the project dir (in case terminal starts elsewhere)
	vim.api.nvim_chan_send(vim.b.terminal_job_id, "cd " .. cwd .. "\n")

	vim.cmd("startinsert")
end, {
	buffer = true,
	desc = "Run Love2D project (vsplit terminal)",
	silent = true,
})
