vim.api.nvim_create_autocmd({ "ColorScheme", "VimEnter" }, {
	group = vim.api.nvim_create_augroup("BlinkCmpColors", { clear = true }),
	callback = function()
		local function get_hex(group, attr)
			local hl = vim.api.nvim_get_hl(0, { name = group })
			if hl[attr] then
				return string.format("#%06x", hl[attr])
			end
			return nil
		end

		local menu_bg = get_hex("Pmenu", "bg") or "#1e2124"
		local menu_fg = get_hex("Pmenu", "fg") or "#c9d1d9"
		local selection_bg = get_hex("PmenuSel", "bg") or "#264f78"
		local selection_fg = get_hex("PmenuSel", "fg") or "#ffffff"
		local border_color = get_hex("FloatBorder", "fg") or "#58a6ff"
		local accent_color = get_hex("Function", "fg") or "#79c0ff"
		local keyword_color = get_hex("Keyword", "fg") or "#ff7b72"
		local type_color = get_hex("Type", "fg") or "#ffa657"
		local string_color = get_hex("String", "fg") or "#a5f3fc"
		local comment_color = get_hex("Comment", "fg") or "#484f58"

		vim.api.nvim_set_hl(0, "BlinkCmpMenu", { bg = menu_bg, fg = menu_fg })
		vim.api.nvim_set_hl(0, "BlinkCmpMenuBorder", { fg = border_color, bg = menu_bg })
		vim.api.nvim_set_hl(0, "BlinkCmpMenuSelection", { bg = selection_bg, fg = selection_fg })

		vim.api.nvim_set_hl(0, "BlinkCmpScrollBarThumb", { bg = accent_color })
		vim.api.nvim_set_hl(0, "BlinkCmpScrollBarGutter", { bg = menu_bg })

		vim.api.nvim_set_hl(0, "BlinkCmpLabel", { fg = menu_fg, bg = "NONE" })
		vim.api.nvim_set_hl(0, "BlinkCmpLabelMatch", { fg = accent_color, bold = true })
		vim.api.nvim_set_hl(0, "BlinkCmpLabelDetail", { fg = comment_color })
		vim.api.nvim_set_hl(0, "BlinkCmpLabelDescription", { fg = comment_color })
		vim.api.nvim_set_hl(0, "BlinkCmpLabelDeprecated", { fg = comment_color, strikethrough = true })

		vim.api.nvim_set_hl(0, "BlinkCmpKind", { fg = accent_color })

		vim.api.nvim_set_hl(0, "BlinkCmpKindFunction", { fg = accent_color })
		vim.api.nvim_set_hl(0, "BlinkCmpKindMethod", { fg = accent_color })
		vim.api.nvim_set_hl(0, "BlinkCmpKindVariable", { fg = menu_fg })
		vim.api.nvim_set_hl(0, "BlinkCmpKindKeyword", { fg = keyword_color })
		vim.api.nvim_set_hl(0, "BlinkCmpKindText", { fg = menu_fg })
		vim.api.nvim_set_hl(0, "BlinkCmpKindSnippet", { fg = string_color })
		vim.api.nvim_set_hl(0, "BlinkCmpKindClass", { fg = type_color })
		vim.api.nvim_set_hl(0, "BlinkCmpKindInterface", { fg = type_color })

		vim.api.nvim_set_hl(0, "BlinkCmpSource", { fg = border_color, italic = true })

		vim.api.nvim_set_hl(0, "BlinkCmpDoc", { bg = menu_bg, fg = menu_fg })
		vim.api.nvim_set_hl(0, "BlinkCmpDocBorder", { fg = border_color, bg = menu_bg })
		vim.api.nvim_set_hl(0, "BlinkCmpDocSeparator", { fg = border_color })
		vim.api.nvim_set_hl(0, "BlinkCmpDocCursorLine", { bg = selection_bg })

		vim.api.nvim_set_hl(0, "BlinkCmpSignatureHelp", { bg = menu_bg, fg = menu_fg })
		vim.api.nvim_set_hl(0, "BlinkCmpSignatureHelpBorder", { fg = border_color, bg = menu_bg })
		vim.api.nvim_set_hl(0, "BlinkCmpSignatureHelpActiveParameter", { fg = accent_color, bold = true, underline = true })

		vim.api.nvim_set_hl(0, "BlinkCmpGhostText", { fg = comment_color, italic = true })
	end,
})

return {
  {
    "saghen/blink.cmp",
    cond = not vim.g.is_vscode,
    dependencies = {
      "rafamadriz/friendly-snippets",
      "L3MON4D3/LuaSnip",
    },
    version = "1.*",

    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      keymap = {
        preset = "super-tab",
        ["<C-l>"] = {
          function(cmp)
            cmp.show()
          end,
        },
        ["<CR>"] = {
          function(cmp)
            -- Only handle if menu is visible; otherwise let next command run
            if cmp.is_visible() then
              cmp.accept()
              return true -- stop, don't run "fallback"
            end
            -- returning nil/false continues to next command ("fallback")
          end,
          "fallback",
        },
      },
      appearance = {
        nerd_font_variant = "mono",
      },
      completion = {
        menu = {
          border = "solid",
          winhighlight =
          "Normal:BlinkCmpMenu,FloatBorder:BlinkCmpMenuBorder,CursorLine:BlinkCmpMenuSelection,Search:None",
          draw = {
            padding = { 0, 0 },
            components = {
              kind_icon = {
                text = function(ctx)
                  return ctx.kind_icon .. ctx.icon_gap .. " "
                end,
                highlight = function(ctx)
                  local text = " " .. ctx.kind_icon .. ctx.icon_gap .. " "
                  return { { 0, #text, group = ctx.kind_hl or "BlinkCmpKind", priority = 20000 } }
                end,
              },
            },
          },
        },
        documentation = {
          auto_show = true,
          window = {
            border = "solid",
            winhighlight = "Normal:BlinkCmpDoc,FloatBorder:BlinkCmpDocBorder,CursorLine:BlinkCmpDocCursorLine",
          },
        },
      },
      signature = {
        window = {
          border = "solid",
          winhighlight = "Normal:BlinkCmpSignatureHelp,FloatBorder:BlinkCmpSignatureHelpBorder",
        },
      },

      -- Default list of enabled providers defined so that you can extend it
      -- elsewhere in your config, without redefining it, due to `opts_extend`
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
      },
      fuzzy = { implementation = "prefer_rust_with_warning" },
    },
    opts_extend = { "sources.default" },
  },
}
