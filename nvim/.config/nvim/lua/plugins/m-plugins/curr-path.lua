return {
	name = "curr-path",
	cond = not vim.g.is_vscode,
	dir = vim.fn.stdpath("config") .. "/lua/plugins/m-plugins/curr-path",
	virtual = true,
	config = function()
		local function get_project_root()
			local root = vim.fs.root(0, { ".git" })
			if not root then
				root = vim.fs.root(0, { "Makefile", "CMakeLists.txt", "Cargo.toml", "package.json" })
			end
			return root or vim.fn.getcwd()
		end

		local function get_relative_path(full_path)
			local root = get_project_root()
			if full_path:sub(1, #root) == root then
				local rel = full_path:sub(#root + 2)
				return rel ~= "" and rel or "."
			end
			return full_path
		end

		vim.api.nvim_create_user_command("CurrFile", function()
			local path = get_relative_path(vim.fn.expand("%:p"))
			vim.fn.setreg("+", path)
			vim.notify("Copied: " .. path)
		end, { desc = "Copy current file path relative to project root" })

		vim.api.nvim_create_user_command("CurrDir", function()
			local path = get_relative_path(vim.fn.expand("%:p:h"))
			vim.fn.setreg("+", path)
			vim.notify("Copied: " .. path)
		end, { desc = "Copy current directory relative to project root" })
	end,
}
