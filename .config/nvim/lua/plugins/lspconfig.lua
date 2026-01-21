---@diagnostic disable: param-type-not-match
return {
	{
		"neovim/nvim-lspconfig",
		cond = not vim.g.is_vscode,
		dependencies = {
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",
			-- lazydev.nvim removed - conflicts with .luarc.json approach
			-- For plugin API completions, manually add to .luarc.json if needed
		},
		config = function()
			require("mason").setup()
			---@diagnostic disable-next-line: missing-fields
			require("mason-lspconfig").setup({
				ensure_installed = {
					"lua_ls",
					"rust_analyzer",
					"gopls",
					"bashls",
					"clangd",
					"pyright",
				},
			})
			require("mason-tool-installer").setup({
				ensure_installed = {
					"stylua",
					"selene",
					"prettier",
					"prettierd",
					"ruff",
				},
			})

			-- Enable lua_ls (configured by .luarc.json files)
			vim.lsp.enable("lua_ls")

			-- Disable ruff LSP (using conform for formatting instead)
			vim.lsp.enable("ruff", false)

			-- Gleam LSP (nvim 0.11+ API)
			vim.lsp.config.gleam = {
				cmd = { "gleam", "lsp" },
				filetypes = { "gleam" },
				root_markers = { "gleam.toml" },
			}
			vim.lsp.enable("gleam")

			-- Odin LSP (nvim 0.11+ API)
			vim.lsp.config.ols = {
				cmd = { "ols" },
				filetypes = { "odin" },
				root_markers = { "ols.json", ".git" },
			}
			vim.lsp.enable("ols")

			-- GDScript LSP (connects to Godot editor's built-in LSP)
			vim.lsp.config.gdscript = {
				cmd = vim.lsp.rpc.connect("127.0.0.1", 6005),
				filetypes = { "gdscript", "gd" },
				root_markers = { "project.godot", ".git" },
			}
			vim.lsp.enable("gdscript")

			-- GLSL LSP (glsl_analyzer)
			vim.lsp.config.glsl_analyzer = {
				cmd = { "glsl_analyzer" },
				filetypes = { "glsl", "vert", "frag", "geom", "comp", "tesc", "tese" },
				root_markers = { ".git" },
			}
			vim.lsp.enable("glsl_analyzer")

			-- this is handeled by conform
			-- vim.keymap.set("n", "<leader>lf", function() vim.lsp.buf.format() end)

			vim.keymap.set("i", "<C-k>", vim.lsp.buf.signature_help)
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("my.lsp", {}),
				callback = function(args)
					local client = assert(vim.lsp.get_client_by_id(args.data.client_id))

					-- Enable auto-completion. Note: Use CTRL-Y to select an item. |complete_CTRL-Y|
					if client:supports_method("textDocument/completion") then
						-- Optional: trigger autocompletion on EVERY keypress. May be slow!
						vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = false })
					end

					local opts = { buffer = args.buf }

					-- Open the diagnostic under the cursor in a float window
					vim.keymap.set("n", "<leader>d", function()
						vim.diagnostic.open_float({
							border = "single",
						})
					end, opts)

					vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
					-- Source actions keymap
					vim.keymap.set("n", "<leader>ls", function()
						vim.lsp.buf.code_action({
							context = {
								only = { "source" }, -- Request all "source" actions
								diagnostics = {},
							},
						})
					end, opts)

					-- Attach navic if the server supports document symbols
					if client:supports_method("textDocument/documentSymbol") then
						local navic_ok, navic = pcall(require, "nvim-navic")
						if navic_ok then
							navic.attach(client, args.buf)
						end
					end

					-- Let conform handle formatting with lsp_format = "fallback"
					-- No need to disable LSP formatting capabilities

					-- Attach twoslash-queries for TypeScript/JavaScript
					if client.name == "typescript-tools" then
						local twoslash_ok, twoslash = pcall(require, "twoslash-queries")
						if twoslash_ok then
							twoslash.attach(client, args.buf)
						end
					end

					-- Format-on-save is handled by conform.nvim, not LSP directly
				end,
			})
		end,
	},
}
