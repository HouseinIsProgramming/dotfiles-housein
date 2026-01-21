return {
	"jiaoshijie/undotree",
	cond = not vim.g.is_vscode,
	---@module 'undotree.collector'
	---@type UndoTreeCollector.Opts
	opts = {
		-- your options
	},
	keys = { -- load the plugin only when using it's keybinding:
		{ "<leader>uw", "<cmd>lua require('undotree').toggle()<cr>" },
	},
}
