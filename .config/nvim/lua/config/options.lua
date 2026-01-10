-- general
vim.o.number = true
vim.o.scrolloff = 16
vim.o.signcolumn = "yes"
vim.o.clipboard = "unnamedplus"

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
vim.o.expandtab = false

-- folding
vim.o.foldcolumn = "0"
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldenable = true
vim.o.foldmethod = "indent"

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
