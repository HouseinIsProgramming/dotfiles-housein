return {
	"mikavilpas/yazi.nvim",
	event = "VeryLazy",
	opts = {
		open_for_directories = false,
		vim.keymap.set("n", "<leader>i", ":Yazi<CR>"),
	},
}
