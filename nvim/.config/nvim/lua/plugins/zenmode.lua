return {
	"folke/zen-mode.nvim",
	opts = {
		window = {
			backdrop = 0.95,
		},
		plugins = {
			tmux = { enabled = false },
		},
	},
	keys = {
		{ "<leader>uz", "<cmd>ZenMode<cr>", desc = "Zen Mode" },
	},
}
