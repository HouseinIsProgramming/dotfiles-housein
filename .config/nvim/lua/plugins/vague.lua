return {
	"vague2k/vague.nvim",
	lazy = false, -- make sure we load this during startup if it is your main colorscheme
	priority = 1000, -- make sure to load this before all the other plugins
	config = function()
		-- NOTE: you do not need to call setup if you don't want to.
		require("vague").setup({
			-- optional configuration here
		})
		-- vim.cmd("colorscheme vague")
		-- local function set_blink_highlights()
		-- 	vim.api.nvim_set_hl(0, "BlinkCmpMenu", { fg = "NONE", bg = "#18181B" })
		-- 	vim.api.nvim_set_hl(0, "BlinkCmpMenuBorder", { fg = "NONE", bg = "#27272A" })
		-- end
		--
		-- vim.api.nvim_create_autocmd("ColorScheme", {
		-- 	pattern = "*",
		-- 	callback = set_blink_highlights,
		-- 	desc = "Set custom BlinkCmp highlights after colorscheme loads",
		-- })
	end,
}
