return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		vim.fn.reg_recording()
		function macro_status()
			local recording_register = vim.fn.reg_recording()
			if recording_register ~= "" then
				-- You can customize this string
				return "Recording @" .. recording_register
			else
				return "" -- Return empty string if not recording
			end
		end

		vim.o.cmdheight = 0

		require("lualine").setup({
			options = {
				icons_enabled = true,
				theme = "auto",
				component_separators = { left = "", right = "" },
				section_separators = { left = "", right = "" },
				disabled_filetypes = { "alpha", "dashboard", "NvimTree", "Outline" },
				ignore_focus = {},
				always_divide_middle = true,
				globalstatus = false,
				refresh = {
					statusline = 1000,
					tabline = 1000,
					winbar = 1000,
				},
			},
			sections = {
				lualine_a = { "mode" },
				lualine_b = { "branch" },
				lualine_c = {
					{
						"filename",
						path = 0,
					},
				},
				lualine_x = { "diagnostics" },
				lualine_y = { macro_status, "filetype" },
			},
		})
	end,
}
