vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(ev)
		local client = vim.lsp.get_client_by_id(ev.data.client_id)
		if client:supports_method("textDocument/completion") then
			vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
		end
	end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
	group = vim.api.nvim_create_augroup("highlight_yank", {}),
	desc = "Hightlight selection on yank",
	pattern = "*",
	callback = function()
		vim.highlight.on_yank({ higroup = "IncSearch", timeout = 300 })
	end,
})

vim.api.nvim_create_autocmd("BufReadPost", {
	group = vim.api.nvim_create_augroup("RememberCursorPosition", { clear = true }),
	callback = function()
		-- Only jump if the mark exists, is not the first line (often default),
		-- and is within the file's current bounds.
		if vim.fn.line("'\"'") > 1 and vim.fn.line("'\"'") <= vim.fn.line("$") then
			vim.cmd('normal! g`"')
		end
	end,
})
