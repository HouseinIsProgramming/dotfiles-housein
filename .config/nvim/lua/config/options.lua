-- general
vim.o.number = true
vim.o.scrolloff = 8
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

-- tab vs spaces
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.expandtab = true

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
  virtual_text = true,
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})
