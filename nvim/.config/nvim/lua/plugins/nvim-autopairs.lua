return {
	"windwp/nvim-autopairs",
	event = "InsertEnter",
	config = function()
		local npairs = require("nvim-autopairs")
		local Rule = require("nvim-autopairs.rule")
		local cond = require("nvim-autopairs.conds")

		npairs.setup({
			-- defaults are fine; keeping explicit for clarity
			map_bs = true,
			map_cr = true,
		})

		npairs.add_rules({
			Rule("<", ">")
				-- create the pair in reasonable cases
				:with_pair(cond.not_after_text(">"))
				-- when you type `>`, jump over an existing `>` instead of inserting
				:with_move(
					cond.after_text(">")
				),
		})
	end,
}
