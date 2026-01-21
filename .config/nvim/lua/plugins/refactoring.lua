return {
	"ThePrimeagen/refactoring.nvim",
	cond = not vim.g.is_vscode,
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
	},
	lazy = false,
	opts = {},
	config = function()
		require("refactoring").setup({})
		
		-- Set up keymaps after plugin is loaded
		vim.keymap.set({ "n", "x" }, "<leader>cr", function()
			require("refactoring").select_refactor()
		end, { desc = "Ref: Select refactor" })
		
		vim.keymap.set({ "x", "n" }, "<leader>cv", function()
			require("refactoring").debug.print_var()
		end, { desc = "Ref: Print variable" })
		
		vim.keymap.set("n", "<leader>cq", function()
			require("refactoring").debug.cleanup({})
		end, { desc = "Ref: Cleanup" })
	end,
}
