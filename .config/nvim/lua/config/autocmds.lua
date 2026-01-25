-- Abbreviations
vim.cmd.cabbr({ args = { "<expr>", "%%", "expand('%:p:h')" } })

vim.filetype.add({
	extension = {
		fs = "glsl",
		vs = "glsl",
		vert = "glsl",
		frag = "glsl",
		geom = "glsl",
		comp = "glsl",
	},
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

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

local view_group = augroup("auto_view", { clear = true })
autocmd({ "BufWinLeave", "BufWritePost", "WinLeave" }, {
	desc = "Save view with mkview for real files",
	group = view_group,
	callback = function(args)
		if vim.b[args.buf].view_activated then
			vim.cmd.mkview({ mods = { emsg_silent = true } })
		end
	end,
})
autocmd("BufWinEnter", {
	desc = "Try to load file view if available and enable view saving for real files",
	group = view_group,
	callback = function(args)
		if not vim.b[args.buf].view_activated then
			local filetype = vim.api.nvim_get_option_value("filetype", { buf = args.buf })
			local buftype = vim.api.nvim_get_option_value("buftype", { buf = args.buf })
			local ignore_filetypes = { "gitcommit", "gitrebase", "svg", "hgcommit" }
			if buftype == "" and filetype and filetype ~= "" and not vim.tbl_contains(ignore_filetypes, filetype) then
				vim.b[args.buf].view_activated = true
				vim.cmd.loadview({ mods = { emsg_silent = true } })
			end
		end
	end,
})
