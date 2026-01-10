return {
	"pmizio/typescript-tools.nvim",
	dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
	ft = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
	opts = {
		settings = {
			separate_diagnostic_server = true,
			publish_diagnostic_on = "insert_leave",
			tsserver_file_preferences = {
				includeInlayParameterNameHints = "all",
				includeInlayPropertyDeclarationTypeHints = true,
				includeInlayFunctionLikeReturnTypeHints = true,
			},
		},
	},
}
