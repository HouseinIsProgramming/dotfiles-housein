return {
	"mikavilpas/yazi.nvim",
	cond = not vim.g.is_vscode,
	event = "VeryLazy",
	opts = {
		open_for_directories = false,
		vim.keymap.set("n", "<leader>i", ":Yazi<CR>"),
	},
}
