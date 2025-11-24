return {
	"L3MON4D3/LuaSnip",
	build = "make install_jsregexp",
	dependencies = {
		"rafamadriz/friendly-snippets",
	},
	config = function()
		local luasnip = require("luasnip")
		local vscode_loader = require("luasnip.loaders.from_vscode")

		vscode_loader.lazy_load()
		vscode_loader.lazy_load({ paths = vim.fn.stdpath("config") .. "/snippets" })

		local function load_project_snippets()
			local snippet_dirs = { ".vscode", ".snippets", "snippets" }
			local cwd = vim.fn.getcwd()

			for _, dir in ipairs(snippet_dirs) do
				local path = cwd .. "/" .. dir
				if vim.fn.isdirectory(path) == 1 then
					vscode_loader.lazy_load({ paths = { path } })
				end
			end
		end

		load_project_snippets()

		vim.api.nvim_create_autocmd("DirChanged", {
			group = vim.api.nvim_create_augroup("LuaSnipProjectSnippets", { clear = true }),
			callback = load_project_snippets,
		})

		luasnip.config.setup({
			history = true,
			delete_check_events = "TextChanged",
		})
	end,
}
