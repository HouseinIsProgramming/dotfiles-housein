vim.o.number = true
vim.o.relativenumber = true
vim.o.scrolloff = 8
vim.o.signcolumn = "yes"
vim.o.termguicolors = true
vim.o.wrap = false
vim.o.tabstop = 2
vim.o.swapfile = false
vim.g.mapleader = " "
vim.o.winborder = "rounded"
vim.o.clipboard = "unnamedplus"

require("plugins")
require("setup")
require("autocmds")
require("keymaps")

vim.cmd("set completeopt+=noselect")
vim.cmd(":hi statusline guibg=NONE")

