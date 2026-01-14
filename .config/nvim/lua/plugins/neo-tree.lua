return {
	"nvim-neo-tree/neo-tree.nvim",
	enabled = false,
	branch = "v3.x",
	lazy = false,
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons",
		"MunifTanjim/nui.nvim",
	},
	config = function()
		require("neo-tree").setup({
			close_if_last_window = true,
			sync_root_with_cwd = true,
			filesystem = {
				follow_current_file = {
					enabled = true,
					leave_dirs_open = true,
				},
				use_libuv_file_watcher = true,
			},
			window = {
				width = 35,
			},
		})

		vim.api.nvim_create_autocmd("BufReadPost", {
			once = true,
			callback = function()
				vim.schedule(function()
					vim.cmd("Neotree show")
				end)
			end,
		})


		vim.keymap.set("n", "<leader>e", function()
			if vim.bo.filetype == "neo-tree" then
				vim.cmd("wincmd p")
			else
				vim.cmd("Neotree focus")
			end
		end, { silent = true })
	end,
}
