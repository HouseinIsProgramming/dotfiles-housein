return {
	"karb94/neoscroll.nvim",
	config = function()
		require("neoscroll").setup({
			mappings = { "<C-u>", "<C-d>", "<C-b>", "<C-f>", "<C-y>", "<C-e>", "zt", "zz", "zb" },
			hide_cursor = false,
			stop_eof = false,
			duration_multiplier = 0.3,
			respect_scrolloff = false,
			cursor_scrolls_alone = true,
			easing = "linear",
			performance_mode = false,
		})
	end,
}
