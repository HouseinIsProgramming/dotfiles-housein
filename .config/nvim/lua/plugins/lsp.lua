return {
	-- 1. Install servers
	{
		"williamboman/mason.nvim",
		build = ":MasonUpdate",
	},

	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = { "williamboman/mason.nvim" },
	},

	-- 3. Actual LSP configuration
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
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
				},
			},
		},
		config = function()
			---------------------------------------------------------------------------
			-- Mason ------------------------------------------------------------------
			---------------------------------------------------------------------------
			require("mason").setup()

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
			-- Lua
			lspconfig.lua_ls.setup({
				-- capabilities = capabilities,
				-- on_attach = on_attach,
				-- settings = {
				-- 	Lua = {
				-- 		version = "LuaJIT",
				-- 		diagnostics = { globals = { "vim", "require", "hs" } },
				-- 		workspace = { library = vim.api.nvim_get_runtime_file("", true) },
				-- 		telemetry = { enable = false },
				-- 	},
				-- },
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
}
