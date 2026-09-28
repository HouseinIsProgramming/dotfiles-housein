-- Disable netrw in VSCode (it opens when VSCode passes directory path)
if vim.g.is_vscode then
	vim.g.loaded_netrw = 1
	vim.g.loaded_netrwPlugin = 1
end

-- general
vim.o.number = true
vim.o.scrolloff = 16
vim.o.signcolumn = "yes"
vim.o.clipboard = "unnamedplus"
vim.o.autoread = true

-- searching
vim.o.smartcase = true
vim.o.ignorecase = true

-- visual
vim.o.winborder = "solid"
vim.o.confirm = true
vim.o.cursorline = true
vim.o.termguicolors = true
vim.o.splitright = true
vim.cmd(":hi statusline guibg=NONE")
vim.o.laststatus = 0

-- tab vs spaces
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true

-- folding
local function custom_foldexpr()
	local lnum = vim.v.lnum
	local line = vim.fn.getline(lnum)

	-- Separator pattern: ========== something ==========
	if line:match("^==========.*==========$") then
		return ">1"
	end

	-- Try treesitter folding first
	local ok, ts_fold = pcall(vim.treesitter.foldexpr)
	if ok and ts_fold and ts_fold ~= "0" and ts_fold ~= "" then
		return ts_fold
	end

	-- Fallback to indent-based
	local indent = vim.fn.indent(lnum)
	local sw = vim.bo.shiftwidth > 0 and vim.bo.shiftwidth or vim.o.shiftwidth
	if sw == 0 then sw = 4 end
	return math.floor(indent / sw)
end

_G.CustomFoldExpr = custom_foldexpr

vim.o.foldcolumn = "0"
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldenable = true
vim.o.foldmethod = "expr"
vim.o.foldexpr = "v:lua.CustomFoldExpr()"

vim.o.undofile = true

-- warping
vim.o.wrap = true
vim.o.linebreak = true

-- better native autocomplete
vim.cmd("set completeopt=menu,menuone,noselect")
vim.opt.completeopt = { "menu", "menuone", "noselect" }
vim.o.wildmenu = true

-- Configure LSP diagnostics
vim.diagnostic.config({
	virtual_text = {
		-- current_line = true,
		virt_text_pos = "eol_right_align",
	},
	signs = true,
	underline = true,
	update_in_insert = false,
	severity_sort = true,
})

---@type MyColors
local colorscheme = "evergarden-fall"
vim.cmd.colorscheme(colorscheme)
