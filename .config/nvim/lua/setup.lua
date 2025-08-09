require("mason").setup()
require("mason-lspconfig").setup()
require("mason-tool-installer").setup({
	ensure_installed = {
		"lua_ls",
		"stylua",
		"typescript-language-server",
		"ocamllsp",
		"ocamlformat",
	},
})

vim.cmd("colorscheme tokyonight-moon")

require("conform").setup({
	formatters_by_ft = {
		lua = { "stylua" },
		python = { "isort", "black" },
		rust = { "rustfmt", lsp_format = "fallback" },
		javascript = { "prettierd", "prettier", stop_after_first = true },
		typescript = { "prettierd", "prettier", stop_after_first = true },
		ocaml = { "ocamlformat" },
	},
	format_on_save = {
		timeout_ms = 500,
		lsp_format = "fallback",
	},
})

require("nvim-autopairs").setup({})
require("mini.ai").setup({})

require("mini.pick").setup()
require("nvim-treesitter.configs").setup({
	ensure_installed = { "svelte", "typescript", "javascript", "c", "lua", "ocaml" },
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
		["<C-d>"] = { "accept" },
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

-- Configure diagnostics
vim.diagnostic.config({
	virtual_text = {
		prefix = "●", -- Customize the prefix (e.g., ●, ✗, etc.)
		spacing = 4, -- Space between the diagnostic and the text
		source = "if_many", -- Show source if there are multiple diagnostics
	},
	signs = true, -- Show signs in the gutter
	underline = true, -- Underline the problematic code
	update_in_insert = false, -- Disable updates in insert mode
	severity_sort = true, -- Sort diagnostics by severity
})

vim.lsp.enable({ "lua_ls", "emmetls", "ts_ls", "html", "ocamllsp" })

vim.api.nvim_create_autocmd("FileType", {
	pattern = "arduino",
	callback = function()
		require("arduino-nvim").setup()
	end,
})
