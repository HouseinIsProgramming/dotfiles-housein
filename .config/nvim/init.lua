vim.pack.add({
	{ src = "https://github.com/neovim/nvim-lspconfig" },
	{ src = "https://github.com/mason-org/mason.nvim" },
	{ src = "https://github.com/nvim-lua/plenary.nvim" },
	{ src = "https://github.com/echasnovski/mini.pick" },
	{ src = "https://github.com/ibhagwan/fzf-lua" },
	{ src = "https://github.com/mikavilpas/yazi.nvim" },
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter" },
	{ src = "https://github.com/mason-org/mason-lspconfig.nvim" },
	{ src = "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim" },
	{ src = "https://github.com/saghen/blink.cmp" },
	{ src = "https://github.com/L3MON4D3/LuaSnip" },
	{ src = "https://github.com/rafamadriz/friendly-snippets" },
})

vim.o.number = true
vim.o.relativenumber = true
vim.o.scrolloff = 8
vim.o.signcolumn = "yes"
vim.o.termguicolors = true
vim.o.wrap = false
vim.o.tabstop = 4
vim.o.swapfile = false
vim.g.mapleader = " "
vim.o.winborder = "rounded"
vim.o.clipboard = "unnamedplus"

require("mason").setup()
require("mason-lspconfig").setup()
require("mason-tool-installer").setup({
	ensure_installed = {
		"lua_ls",
		"stylua",
		"typescript-language-server",
	},
})

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(ev)
		local client = vim.lsp.get_client_by_id(ev.data.client_id)
		if client:supports_method("textDocument/completion") then
			vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
		end
	end,
})
vim.cmd("set completeopt+=noselect")

require("mini.pick").setup()
require("nvim-treesitter.configs").setup({
	ensure_installed = { "svelte", "typescript", "javascript" },
	highlight = { enable = true },
})
require("yazi").setup()

require("blink.cmp").setup({
	snippets = { preset = "luasnip" },
	signature = { enabled = true },
	appearance = {
		use_nvim_cmp_as_default = false,
		nerd_font_variant = "normal",
	},
	sources = {
		default = { "lsp", "path", "snippets", "buffer" },
		providers = {
			cmdline = {
				min_keyword_length = 2,
			},
		},
	},
	keymap = {
		["<C-f>"] = { "accept_and_enter" },
		["<C-l>"] = { "show" },
},
	cmdline = {
		enabled = true,
		completion = { menu = { auto_show = true } },
		keymap = {
			["<CR>"] = { "accept_and_enter", "fallback" },
		},
	},
	completion = {
		menu = {
			border = nil,
			scrolloff = 1,
			scrollbar = false,
			draw = {
				columns = {
					{ "kind_icon" },
					{ "label", "label_description", gap = 1 },
					{ "kind" },
					{ "source_name" },
				},
			},
		},
		documentation = {
			window = {
				border = nil,
				scrollbar = false,
				winhighlight = "Normal:BlinkCmpDoc,FloatBorder:BlinkCmpDocBorder,EndOfBuffer:BlinkCmpDoc",
			},
			auto_show = true,
			auto_show_delay_ms = 500,
		},
	},
})

require("luasnip.loaders.from_vscode").lazy_load()

vim.lsp.config("lua_ls", {
	settings = {
		Lua = {
			runtime = {
				version = "LuaJIT",
			},
			diagnostics = {
				globals = {
					"vim",
					"require",
				},
			},
			workspace = {
				library = vim.api.nvim_get_runtime_file("", true),
			},
			telemetry = {
				enable = false,
			},
		},
	},
})

vim.keymap.set("n", "<leader>ff", ":FzfLua files<CR>")
vim.keymap.set("n", "<leader>fg", ":FzfLua grep<CR>")
vim.keymap.set("n", "<leader>fr", ":FzfLua lsp_references<CR>")
vim.keymap.set("n", "<leader>fb", ":FzfLua buffers<CR>")
vim.keymap.set("n", "<leader>fo", ":FzfLua oldfiles<CR>")
vim.keymap.set("n", "<leader>fi", ":FzfLua lsp_implementations<CR>")
vim.keymap.set("n", "<leader>fs", ":FzfLua lsp_document_symbols<CR>")
vim.keymap.set("n", "<leader>fc", ":FzfLua lsp_code_actions<CR>")
vim.keymap.set("n", "<leader>fh", ":Pick help<CR>")
vim.keymap.set("n", "<leader>i", ":Yazi<CR>")
vim.keymap.set("n", "<leader>cf", vim.lsp.buf.format)
vim.lsp.enable({ "lua_ls", "emmetls" })

vim.cmd(":hi statusline guibg=NONE")
