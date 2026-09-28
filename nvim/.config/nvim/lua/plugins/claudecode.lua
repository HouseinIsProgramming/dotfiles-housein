return {
	"coder/claudecode.nvim",
	dependencies = { "folke/snacks.nvim" },
	config = true,
	keys = {
		{ "<leader>a", nil, desc = "AI/Claude Code" },
		{ "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
		{ "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
		{ "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
		{ "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
		{ "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select Claude model" },
		{ "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer" },
		{ "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send to Claude" },
		{
			"<leader>as",
			"<cmd>ClaudeCodeTreeAdd<cr>",
			desc = "Add file",
			ft = { "NvimTree", "neo-tree", "oil", "minifiles", "netrw" },
		},
		-- Diff management
		{ "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
		{ "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
	},
}

-- return {
-- 	"coder/claudecode.nvim",
-- 	cond = not vim.g.is_vscode,
-- 	opts = {
-- 		terminal = {
-- 			provider = "none",
-- 		},
-- 	},
-- 	config = function(_, opts)
-- 		require("claudecode").setup(opts)
--
-- 		vim.api.nvim_create_autocmd("OptionSet", {
-- 			pattern = "diff",
-- 			callback = function()
-- 				if vim.wo.diff then
-- 					vim.keymap.set(
-- 						"n",
-- 						"<leader>aa",
-- 						"<cmd>ClaudeCodeDiffAccept<cr>",
-- 						{ buffer = true, desc = "Accept diff" }
-- 					)
-- 					vim.keymap.set(
-- 						"n",
-- 						"<leader>ad",
-- 						"<cmd>ClaudeCodeDiffDeny<cr>",
-- 						{ buffer = true, desc = "Deny diff" }
-- 					)
-- 				end
-- 			end,
-- 		})
-- 	end,
-- }
