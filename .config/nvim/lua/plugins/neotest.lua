return {
	{
		"nvim-neotest/neotest",
		dependencies = {
			"nvim-neotest/nvim-nio",
			"nvim-lua/plenary.nvim",
			"antoinemadec/FixCursorHold.nvim",
			"nvim-treesitter/nvim-treesitter",
			"marilari88/neotest-vitest",
			"nvim-neotest/neotest-jest",
		},
		keys = {
			{ "<leader>tr", "<cmd>Neotest run<cr>", desc = "Run tests" },
			{ "<leader>ti", "<cmd>Neotest output<cr>", desc = "Show output" },
			{ "<leader>ts", "<cmd>Neotest summary<cr>", desc = "Show summary" },
			{ "<leader>ta", "<cmd>lua require('neotest').run.run({ suite = true })<cr>", desc = "Run all tests" },
		},
		config = function()
			require("neotest").setup({
				settings = {
					watch = true,
				},
				adapters = {
					require("neotest-vitest"),
					require("neotest-jest"),
				},
			})
		end,
	},
}
