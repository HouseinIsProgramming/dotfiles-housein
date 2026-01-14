return {
	"nvim-tree/nvim-tree.lua",
	enabled = false,
	version = "*",
	lazy = false,
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},
	config = function()
		require("nvim-tree").setup({
			view = {
				width = 35,
			},
			update_focused_file = {
				enable = true,
				update_root = true,
			},
		})

		vim.api.nvim_create_autocmd("BufReadPost", {
			once = true,
			callback = function()
				vim.schedule(function()
					local api = require("nvim-tree.api")
					local prev_win = vim.api.nvim_get_current_win()
					api.tree.open()
					vim.api.nvim_set_current_win(prev_win)
				end)
			end,
		})
		vim.keymap.set("n", "<leader>e", function()
			local api = require("nvim-tree.api")
			local view = require("nvim-tree.view")
			if view.is_visible() and api.tree.is_tree_buf() then
				vim.cmd("wincmd p")
			else
				api.tree.focus()
			end
		end, { silent = true })

		vim.api.nvim_create_autocmd("BufEnter", {
			nested = true,
			callback = function()
				local api = require("nvim-tree.api")
				if #vim.api.nvim_list_wins() == 1 and api.tree.is_tree_buf() then
					vim.cmd("quit")
				end
			end,
		})
	end,
}
