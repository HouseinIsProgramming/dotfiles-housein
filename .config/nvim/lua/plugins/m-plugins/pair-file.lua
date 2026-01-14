return {
	name = "pair-file",
	dir = vim.fn.stdpath("config") .. "/lua/plugins/m-plugins/pair-file",
	virtual = true,
	config = function()
		local pairs = {
			c = { "h" },
			h = { "c" },
			cpp = { "hpp", "h" },
			hpp = { "cpp", "cc", "cxx" },
			cc = { "hpp", "h" },
			cxx = { "hpp", "h" },
		}

		local function get_project_root()
			local root = vim.fs.root(0, { ".git", "Makefile", "CMakeLists.txt", "compile_commands.json" })
			return root or vim.fn.getcwd()
		end

		local function find_pair_file()
			local current = vim.fn.expand("%:p")
			local ext = vim.fn.expand("%:e")
			local basename = vim.fn.expand("%:t:r")

			local target_exts = pairs[ext]
			if not target_exts then
				vim.notify("No pair defined for ." .. ext, vim.log.levels.WARN)
				return
			end

			local root = get_project_root()

			for _, target_ext in ipairs(target_exts) do
				local pattern = basename .. "." .. target_ext
				local found = vim.fs.find(pattern, {
					path = root,
					type = "file",
					limit = 10,
				})

				for _, file in ipairs(found) do
					if file ~= current then
						vim.cmd.edit(file)
						return
					end
				end
			end

			vim.notify("No pair file found for " .. basename .. "." .. ext, vim.log.levels.WARN)
		end

		vim.api.nvim_create_user_command("PairFile", find_pair_file, { desc = "Switch to header/source pair" })
		vim.keymap.set("n", "<leader>z", find_pair_file, { desc = "Switch to pair file (h/c)" })
	end,
}
