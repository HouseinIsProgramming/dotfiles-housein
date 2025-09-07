return {
	"nvim-tree/nvim-tree.lua",
	version = "*",
	keys = {
		{ "<leader>e", "<cmd>NvimTreeToggle<cr>" },
	},
	lazy = false,
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},
	config = function()
		require("nvim-tree").setup({})
	end,
}
