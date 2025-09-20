return {
	"SmiteshP/nvim-navic",
	lazy = true,
	-- enabled = false,
	opts = {
		lsp = {
			auto_attach = false,
			preference = nil,
		},
		highlight = false,
		separator = " ▸ ",
		depth_limit = 0,
		depth_limit_indicator = "..",
		safe_output = true,
		lazy_update_context = false,
		click = false,
	},
	config = function(opts)
		require("nvim-navic").setup(opts)

		-- Set up winbar to always show filename, with navic when available
		vim.api.nvim_create_autocmd({ "BufEnter", "CursorMoved", "CursorMovedI" }, {
			callback = function()
				-- Skip tiny popup / prompt windows (e.g. Telescope, code-action, etc.)
				local win = vim.api.nvim_get_current_win()
				if vim.api.nvim_win_get_height(win) < 4 then
					return
				end

				local bt = vim.api.nvim_get_option_value("buftype", { buf = 0 })
				if bt ~= "" and bt ~= "acwrite" then
					return
				end -- skip terminal/prompt/etc.

				local ft = vim.api.nvim_get_option_value("filetype", { buf = 0 })
				if ft == "TelescopePrompt" or ft == "TelescopeResults" then
					return
				end
				local navic = require("nvim-navic")
				local filename = vim.fn.expand("%:t")

				if filename == "" then
					filename = "[No Name]"
				end

				local winbar_content = " " .. filename

				if navic.is_available() then
					local location = navic.get_location()
					if location ~= "" then
						winbar_content = winbar_content .. " ▸ " .. location
					end
				end

				vim.opt_local.winbar = winbar_content
			end,
		})
	end,
}
