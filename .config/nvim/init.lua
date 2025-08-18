vim.o.number = true
vim.o.relativenumber = true
vim.o.scrolloff = 8
vim.o.signcolumn = "yes"
vim.o.termguicolors = true
vim.o.wrap = false
vim.o.tabstop = 2
vim.o.shiftwidth = 1
vim.o.swapfile = false
vim.g.mapleader = " "
vim.o.winborder = "rounded"
vim.o.clipboard = "unnamedplus"
vim.o.confirm = true
vim.o.foldcolumn = "1"
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldenable = true
vim.o.foldmethod = "syntax"
vim.o.smartcase = true
vim.o.winborder = "bold"
-- vim.o.wildmenu = true
vim.o.splitright = true

vim.o.foldcolumn = "0" -- '0' is not bad
vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
vim.o.foldlevelstart = 99
vim.o.foldenable = true

require("plugins")
require("setup")
require("autocmds")
require("keymaps")

vim.cmd("set completeopt+=noselect")
vim.cmd(":hi statusline guibg=NONE")
