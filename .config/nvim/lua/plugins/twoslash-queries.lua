return {
	"marilari88/twoslash-queries.nvim",
	cond = not vim.g.is_vscode,
	config = function()
		require("twoslash-queries").setup({
			multi_line = true,
			is_enabled = true,
			highlight = "@string.escape",
		})
		vim.api.nvim_set_keymap("n", "<leader>us", "<cmd>TwoslashQueriesInspect<CR>", {})
		vim.api.nvim_set_keymap("n", "<leader>uc", "<cmd>TwoslashQueriesRemove<CR>", {})
	end,
}
