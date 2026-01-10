return {
	"folke/flash.nvim",
	event = "VeryLazy",
	opts = {},
	keys = {
		{
			"s",
			mode = { "n", "x", "o" },
			function()
				require("flash").jump()
			end,
			desc = "Flash",
		},
		{
			"S",
			mode = { "n", "x", "o" },
			function()
				require("flash").treesitter()
			end,
			desc = "Flash Treesitter",
		},
		{
			"<leader>w",
			mode = { "n", "x", "o" },
			function()
				require("flash").jump({
					-- Force flash to skip the "typing" phase
					search = { mode = "search", max_length = 0, forward = true, wrap = false },
					-- Use a regex that matches the start of every word
					pattern = [[\<\w]],
					label = { position = "overlay" },
				})
			end,
			desc = "Jump to any word forward",
		},
		{
			"<leader>b",
			mode = { "n", "x", "o" },
			function()
				require("flash").jump({
					search = { mode = "search", max_length = 0, forward = false, wrap = false },
					pattern = [[\<\w]],
					label = { position = "overlay" },
				})
			end,
			desc = "Jump to any word backward",
		},
	},
}
