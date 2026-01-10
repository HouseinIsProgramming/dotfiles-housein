return {
	{
		"nvim-treesitter/nvim-treesitter",
		dependencies = {
			"nvim-treesitter/nvim-treesitter-textobjects",
			"nvim-treesitter/nvim-treesitter-refactor",
		},
		build = ":TSUpdate",
		config = function()
			local configs = require("nvim-treesitter.configs")

			configs.setup({
				ensure_installed = { "lua", "javascript", "html", "gdscript", "godot_resource" },
				sync_install = false,
				highlight = { enable = true },
				indent = { enable = true },
				auto_install = true,
				incremental_selection = {
					enable = true,
					keymaps = {
						node_incremental = "<C-o>",
						scope_incremental = false,
						node_decremental = "<C-i>",
					},
				},
				textobjects = {
					move = {
						enable = true,
						set_jumps = true, -- whether to set jumps in the jumplist
						goto_next_start = {
							["]m"] = "@function.outer",
							["])"] = "@class.outer",
							["]]"] = { query = "@function.outer", desc = "Next function start" },
						},
						goto_previous_start = {
							["[m"] = "@function.outer",
							["[("] = "@class.outer",
							["[["] = { query = "@function.outer", desc = "Previous function start" },
						},
					},
					select = {
						enable = true,
						lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
						keymaps = {
							-- You can use the capture groups defined in textobjects.scm
							["af"] = "@function.outer",
							["if"] = "@function.inner",
							["ac"] = "@class.outer",
							["ic"] = "@class.inner",
						},
					},
				},
			})
		end,
	},
}
