return {
	"antosha417/nvim-lsp-file-operations",
	cond = not vim.g.is_vscode,
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-tree.lua",
	},
	config = function()
		require("lsp-file-operations").setup()
	end,
}
