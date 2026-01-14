return {
	"coder/claudecode.nvim",
	opts = {
		terminal = {
			provider = "none",
		},
	},
	config = function(_, opts)
		require("claudecode").setup(opts)

		vim.api.nvim_create_autocmd("OptionSet", {
			pattern = "diff",
			callback = function()
				if vim.wo.diff then
					vim.keymap.set(
						"n",
						"<leader>aa",
						"<cmd>ClaudeCodeDiffAccept<cr>",
						{ buffer = true, desc = "Accept diff" }
					)
					vim.keymap.set(
						"n",
						"<leader>ad",
						"<cmd>ClaudeCodeDiffDeny<cr>",
						{ buffer = true, desc = "Deny diff" }
					)
				end
			end,
		})
	end,
}
