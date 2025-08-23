return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	config = function()
		require("nvim-treesitter.configs").setup({
			ensure_installed = {
				-- Base
				"lua",
				"vim",
				"vimdoc",
				"query",
				-- Web Development
				"html",
				"css",
				"scss",
				"javascript",
				"typescript",
				"tsx",
				-- "jsx",
				"json",
				"jsonc",
				"yaml",
				"toml",
				"markdown",

				"markdown_inline",
				-- Other useful parsers
				"bash",
				"dockerfile",
				"gitignore",
				"regex",
			},
			auto_install = true,
			highlight = {
				enable = true,
				additional_vim_regex_highlighting = false,
			},
			indent = {
				enable = true,
			},
			incremental_selection = {
				enable = true,
				keymaps = {
					init_selection = "<C-space>",
					node_incremental = "<C-space>",
					scope_incremental = false,
					node_decremental = "<bs>",
				},
			},
		})
	end,
}

