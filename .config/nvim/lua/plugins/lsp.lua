return {
	{
		"williamboman/mason.nvim",
		dependencies = {
			"williamboman/mason-lspconfig.nvim",
			"neovim/nvim-lspconfig",
			"artemave/workspace-diagnostics.nvim",
		},
		opts = {
			servers = {
				lua_ls = {
					settings = {
						Lua = {
							version = "LuaJIT",
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
				},
				vtsls = {
					on_attach = function(client, bufnr)
						require("workspace-diagnostics").populate_workspace_diagnostics(client, bufnr)
					end,
				},
				eslint = {},
				tailwindcss = {},
			},
		},
		config = function(_, opts)
			require("mason").setup()

			require("mason-lspconfig").setup({
				ensure_installed = { "lua_ls", "eslint", "vtsls", "tailwindcss" },
			})
			local lspconfig = require("lspconfig")

			for server, config in pairs(opts.servers) do
				-- vim.lsp.config(server, config)
				lspconfig[server].setup(config)
				vim.lsp.enable(server)
			end
		end,
	},
}
