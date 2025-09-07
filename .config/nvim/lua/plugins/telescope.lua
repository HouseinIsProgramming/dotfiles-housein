return {
	"nvim-telescope/telescope.nvim",
	keys = {
		{ "<leader>ff", "<cmd>Telescope find_files<cr>" },
		{ "<leader>fg", "<cmd>Telescope live_grep<cr>" },
		{ "<leader>fr", "<cmd>Telescope lsp_references<cr>" },
		{ "<leader>fb", "<cmd>Telescope buffers<cr>" },
		{ "<leader>fd", "<cmd>Telescope diagnostics<cr>" },
		{ "<leader>fo", "<cmd>Telescope oldfiles<cr>" },
		{ "<leader>fi", "<cmd>Telescope lsp_implementations<cr>" },
		{ "<leader>fs", "<cmd>Telescope lsp_document_symbols<cr>" },
		{ "<leader>fS", "<cmd>Telescope lsp_workspace_symbols<cr>" },
		-- { "<leader>lc", "<cmd>Telescope lsp_code_actions<cr>" },
	},
	lazy = false,
	tag = "0.1.8",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-telescope/telescope-ui-select.nvim",
	},
	config = function()
		require("telescope").load_extension("ui-select")
	end,
}
