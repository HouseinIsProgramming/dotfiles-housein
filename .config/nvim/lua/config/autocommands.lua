vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", {}),
	callback = function(ev)
		vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc" -- Enable completion triggered by <c-x><c-o>

		local opts = { buffer = ev.buf }

		-- Open the diagnostic under the cursor in a float window
		vim.keymap.set("n", "<leader>d", function()
			vim.diagnostic.open_float({
				border = "single",
			})
		end, opts)
		vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
		vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
		vim.keymap.set("n", "gI", vim.lsp.buf.implementation, opts)
		vim.keymap.set("n", "gy", vim.lsp.buf.type_definition, opts)
		vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
		vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
		vim.keymap.set("n", "gK", vim.lsp.buf.signature_help, opts)
		vim.keymap.set("i", "<C-k>", vim.lsp.buf.signature_help, opts)
		vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
		vim.keymap.set(
			"n",
			"<leader>ls", -- Or any keymap you prefer, e.g., "leader source"
			function()
				vim.lsp.buf.code_action({
					context = {
						only = { "source" }, -- Request all "source" actions
						diagnostics = {},
					},
					-- We remove 'apply = true' to get a list instead of an immediate action
				})
			end,
			opts
		)

		-- Attach navic if the server supports document symbols
	end,
})

local function set_blink_highlights()
	-- Completion Menu Background
	vim.api.nvim_set_hl(0, "BlinkCmpMenu", { fg = "NONE", bg = "#18181B" })
	vim.api.nvim_set_hl(0, "BlinkCmpMenuBorder", { fg = "NONE", bg = "#27272A" })

	-- Highlight for the SELECTED completion menu item
	vim.api.nvim_set_hl(0, "BlinkCmpMenuSelection", { fg = "NONE", bg = "#3B4252" }) -- Example: distinct background for selected item
	-- Highlight for the main label text
	vim.api.nvim_set_hl(0, "BlinkCmpLabel", { fg = "#D8DEE9", bg = "NONE" }) -- Example: light text for labels
	vim.api.nvim_set_hl(0, "BlinkCmpKind", {
		fg = "#A3BE8C",
		bg = "NONE",
		bold = true,
	})

	vim.api.nvim_set_hl(0, "BlinkCmpKindFunction", { fg = "#8FBCBB", bold = true }) -- Teal
	vim.api.nvim_set_hl(0, "BlinkCmpKindMethod", { fg = "#8FBCBB", bold = true }) -- Teal
	vim.api.nvim_set_hl(0, "BlinkCmpKindVariable", { fg = "#EBCB8B", bold = true }) -- Yellow
	vim.api.nvim_set_hl(0, "BlinkCmpKindKeyword", { fg = "#B48EAD", bold = true }) -- Purple
	vim.api.nvim_set_hl(0, "BlinkCmpKindText", { fg = "#BF616A", bold = false }) -- Reddish
	vim.api.nvim_set_hl(0, "BlinkCmpKindSnippet", { fg = "#D08770", bold = false }) -- Yellowish
end

vim.api.nvim_create_autocmd("ColorScheme", {
	pattern = "*",
	callback = set_blink_highlights,
	desc = "Set custom BlinkCmp highlights after colorscheme loads",
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

-- Love2D project detection and keymap setup
local love_group = augroup("love2d_project", { clear = true })
autocmd({ "BufEnter", "DirChanged" }, {
	desc = "Detect Love2D project and setup run keymap",
	group = love_group,
	callback = function()
		local cwd = vim.fn.getcwd()
		local main_lua = cwd .. "/main.lua"
		local conf_lua = cwd .. "/conf.lua"

		-- Check if it's a Love2D project (has main.lua or conf.lua)
		if vim.fn.filereadable(main_lua) == 1 or vim.fn.filereadable(conf_lua) == 1 then
			-- Set up the keymap for this buffer
			vim.keymap.set("n", "<leader>lr", function()
				-- Close any existing floaterm
				vim.cmd("FloatermKill!")
				-- Run Love2D project in a new floaterm
				vim.cmd("FloatermNew --autoclose=2 love .")
			end, {
				buffer = true,
				desc = "Run Love2D project",
				silent = true,
			})
		else
			-- Remove the keymap if not in a Love2D project
			pcall(vim.keymap.del, "n", "<leader>lr", { buffer = true })
		end
	end,
})
