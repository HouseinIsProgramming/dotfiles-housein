-- example lazy.nvim install setup
return {
	"slugbyte/lackluster.nvim",
	lazy = false,
	priority = 1000,
	init = function()
		-- vim.cmd.colorscheme("lackluster")
		-- vim.cmd.colorscheme("lackluster-night") -- my favorite
		-- vim.cmd.colorscheme("lackluster-mint")
		--
		vim.cmd([[
      hi Folded guibg=#171717 guifg=#F1F5F9
      ]])
	end,
}
