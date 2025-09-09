return {
	-- 1. Install servers
	{
		"williamboman/mason.nvim",
		build = ":MasonUpdate",
	},

	-- {
	-- 	"williamboman/mason-lspconfig.nvim",
	-- 	dependencies = { "williamboman/mason.nvim" },
	-- },

	-- 3. Actual LSP configuration
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"williamboman/mason.nvim",
			-- "williamboman/mason-lspconfig.nvim",
			"b0o/schemastore.nvim",
			"SmiteshP/nvim-navic",
			"artemave/workspace-diagnostics.nvim",
			{
				"folke/lazydev.nvim",
				ft = "lua", -- only load on lua files
				opts = {
					library = {
						{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
					},
					integrations = {
						lspconfig = true,
					},
				},
			},
		},
		config = function()
			---------------------------------------------------------------------------
			-- Mason ------------------------------------------------------------------
			---------------------------------------------------------------------------
			require("mason").setup()
			-- require("mason-lspconfig").setup({
			-- 	ensure_installed = {
			-- 		"emmylua_ls",
			-- 		"vtsls",
			-- 		"html",
			-- 		"cssls",
			-- 		"jsonls",
			-- 		"eslint",
			-- 		"tailwindcss",
			-- 		"taplo",
			-- 		"marksman",
			-- 	},
			-- 	automatic_enable = false, --disable
			-- })
			--
			local lspconfig = require("lspconfig")
			local capabilities = require("blink.cmp").get_lsp_capabilities()

			local function on_attach(client, bufnr)
				local map = function(mode, lhs, rhs)
					vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true })
				end
				map("n", "gd", vim.lsp.buf.definition)
				map("n", "gr", vim.lsp.buf.references)
				map("n", "gI", vim.lsp.buf.implementation)
				map("n", "gy", vim.lsp.buf.type_definition)
				map("n", "gD", vim.lsp.buf.declaration)
				map("n", "K", vim.lsp.buf.hover)
				map("n", "gK", vim.lsp.buf.signature_help)
				map("i", "<C-k>", vim.lsp.buf.signature_help)
				map("n", "<leader>ca", vim.lsp.buf.code_action)
				map("n", "<leader>d", function()
					vim.diagnostic.open_float({ border = "single" })
				end)
				map("n", "<leader>ls", function()
					vim.lsp.buf.code_action({ context = { only = { "source" }, diagnostics = {} } })
				end)

				if client.server_capabilities.documentSymbolProvider then
					local ok, navic = pcall(require, "nvim-navic")
					if ok then
						navic.attach(client, bufnr)
					end
				end
			end

			---------------------------------------------------------------------------
			-- Per-server configuration -----------------------------------------------
			---------------------------------------------------------------------------
			-- Lua (EmmyLua)
			-- lspconfig.emmylua_ls.setup({
			-- 	capabilities = capabilities,
			-- 	on_attach = on_attach,
			-- 	settings = {
			-- 		Lua = {
			-- 			completion = {
			-- 				enable = true,
			-- 			},
			-- 			diagnostics = {
			-- 				enable = true,
			-- 				globals = { "vim", "hs" },
			-- 			},
			-- 			hint = {
			-- 				enable = true,
			-- 			},
			-- 		},
			-- 	},
			-- })

			vim.lsp.enable("emmylua_ls")
			vim.lsp.config("emmylua_ls", {
				capabilities = capabilities,
				on_attach = on_attach,
				settings = {
					Lua = {
						cmd = { "emmylua_ls" },
						filetypes = { "lua" },
						root_markers = {
							".luarc.json",
							".emmyrc.json",
							".luacheckrc",
							".git",
						},
						completion = {
							enable = true,
						},
						diagnostics = {
							enable = true,
							globals = { "vim", "hs" },
						},
						hint = {
							enable = true,
						},
					},
				},
			})

			-- TS/JS (vtsls)
			lspconfig.vtsls.setup({
				capabilities = capabilities,
				on_attach = on_attach,
				settings = {
					typescript = {
						inlayHints = {
							includeInlayParameterNameHints = "literal",
							includeInlayFunctionParameterTypeHints = true,
							includeInlayPropertyDeclarationTypeHints = true,
							includeInlayFunctionLikeReturnTypeHints = true,
							includeInlayEnumMemberValueHints = true,
						},
					},
					vtsls = {
						enableMoveToFileCodeAction = true,
						autoUseWorkspaceTsdk = true,
						experimental = { completion = { enableServerSideFuzzyMatch = true } },
					},
				},
			})

			-- Web
			lspconfig.html.setup({ capabilities = capabilities, on_attach = on_attach })
			lspconfig.cssls.setup({ capabilities = capabilities, on_attach = on_attach })

			-- JSON
			lspconfig.jsonls.setup({
				capabilities = capabilities,
				on_attach = on_attach,
				settings = { json = { schemas = require("schemastore").json.schemas(), validate = { enable = true } } },
			})

			-- ESLint
			lspconfig.eslint.setup({
				capabilities = capabilities,
				on_attach = on_attach,
				settings = {
					codeAction = {
						disableRuleComment = { enable = true, location = "separateLine" },
						showDocumentation = { enable = true },
					},
					format = true,
					run = "onType",
					validate = "on",
					workingDirectory = { mode = "location" },
				},
			})

			-- Tailwind CSS, TOML, Markdown
			lspconfig.tailwindcss.setup({ capabilities = capabilities, on_attach = on_attach })
			lspconfig.taplo.setup({ capabilities = capabilities, on_attach = on_attach })
			lspconfig.marksman.setup({ capabilities = capabilities, on_attach = on_attach })
		end,
	},
	{
		"rachartier/tiny-inline-diagnostic.nvim",
		event = "VeryLazy",
		priority = 1000,
		config = function()
			require("tiny-inline-diagnostic").setup({
				preset = "simple",
				multilines = {
					-- Enable multiline diagnostic messages
					enabled = true,

					-- Always show messages on all lines for multiline diagnostics
					always_show = true,

					-- Trim whitespaces from the start/end of each line
					trim_whitespaces = false,

					-- Replace tabs with this many spaces in multiline diagnostics
					tabstop = 4,
				},
				show_all_diags_on_cursorline = true,
				break_line = {
					-- Enable breaking messages after a specific length
					enabled = true,

					-- Number of characters after which to break the line
					after = 30,
				},
			})
			vim.diagnostic.config({ virtual_text = false }) -- Disable default virtual text
		end,
	},
}
