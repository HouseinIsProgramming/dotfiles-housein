return {
	"HouseinIsProgramming/git-panel",
	enabled = false,
	dir = "~/Documents/Github/Lua/nvim-git-panel", -- local dev
	cond = not vim.g.is_vscode,
	dependencies = {
		"MunifTanjim/nui.nvim",
		"nvim-tree/nvim-web-devicons",
	},
	opts = {},
}
