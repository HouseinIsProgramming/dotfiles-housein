return {
	"L3MON4D3/LuaSnip",
	build = "make install_jsregexp",
	dependencies = {
		"rafamadriz/friendly-snippets",
	},
	config = function()
		local luasnip = require("luasnip")
		local s = luasnip.snippet
		local i = luasnip.insert_node
		local fmt = require("luasnip.extras.fmt").fmt

		local vscode_loader = require("luasnip.loaders.from_vscode")

		vscode_loader.lazy_load()

		local d = luasnip.dynamic_node
		local sn = luasnip.snippet_node

		local comment_styles = {
			c = { "/*", " * ", " */" },
			cpp = { "/*", " * ", " */" },
			java = { "/*", " * ", " */" },
			javascript = { "/*", " * ", " */" },
			javascriptreact = { "/*", " * ", " */" },
			typescript = { "/*", " * ", " */" },
			typescriptreact = { "/*", " * ", " */" },
			go = { "/*", " * ", " */" },
			rust = { "/*", " * ", " */" },
			css = { "/*", " * ", " */" },
			scss = { "/*", " * ", " */" },
			lua = { "--[[", "", "]]" },
			python = { '"""', "", '"""' },
			html = { "<!--", "  ", "-->" },
			xml = { "<!--", "  ", "-->" },
			haskell = { "{-", "", "-}" },
			odin = { "/*", " * ", " */" },
		}

		local function get_comment_style()
			local ft = vim.bo.filetype
			return comment_styles[ft] or { "/*", " * ", " */" }
		end

		local function multiline_comment_node()
			return d(1, function()
				local style = get_comment_style()
				local template = style[1] .. "\n" .. style[2] .. "{}\n" .. style[3]
				return sn(nil, fmt(template, { i(1) }))
			end)
		end

		luasnip.add_snippets("all", {
			s({
				trig = "/*",
				snippetType = "autosnippet",
			}, { multiline_comment_node() }),
			s({
				trig = "**  ",
				wordTrig = false,
				snippetType = "autosnippet",
			}, { multiline_comment_node() }),
		})
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
			enable_autosnippets = true,
		})
	end,
}
