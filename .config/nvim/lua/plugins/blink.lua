return {
	"saghen/blink.cmp",
	dependencies = { "rafamadriz/friendly-snippets", "L3MON4D3/LuaSnip" },

	version = "1.*",
	opts = {
		keymap = {
			preset = "super-tab",
			["<CR>"] = { "accept", "fallback" },
			["<C-l>"] = { "show", "show_documentation", "hide_documentation" },
		},
		appearance = {
			nerd_font_variant = "mono",
			use_nvim_cmp_as_default = true,
		},
		completion = {
			documentation = { auto_show = true },
			menu = {
				draw = {
					columns = { { "label", "label_description", gap = 1 }, { "kind_icon", "kind", gap = 1 } },
				},
			},
		},
		sources = {
			default = { "lazydev", "lsp", "path", "snippets", "buffer" },
			providers = {
				lazydev = {
					name = "LazyDev",
					module = "lazydev.integrations.blink",
					score_offset = 100,
				},
			},
		},

		fuzzy = { implementation = "prefer_rust_with_warning" },
	},
	opts_extend = { "sources.default" },
}
