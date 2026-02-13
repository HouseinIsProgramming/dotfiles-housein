return {
	"MeanderingProgrammer/render-markdown.nvim",
	enabled = false,
	cond = not vim.g.is_vscode,
	opts = {},
	dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.nvim" },
}

