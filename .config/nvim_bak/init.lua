vim.o.number = true
vim.o.relativenumber = false
vim.o.scrolloff = 8
vim.o.signcolumn = "yes"
vim.o.termguicolors = true
vim.o.wrap = false
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.expandtab = true
vim.o.swapfile = false
vim.g.mapleader = " "
vim.o.winborder = "solid"
vim.o.clipboard = "unnamedplus"
vim.o.confirm = true
vim.o.cursorline = true

vim.o.foldcolumn = "1"
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldenable = true
vim.o.foldmethod = "indent"

vim.o.undofile = true
vim.o.foldcolumn = "0"

vim.o.smartcase = true
vim.o.ignorecase = true
-- vim.o.wildmenu = true
vim.o.splitright = true

require("config.lazy")

require("config.autocmds")
require("config.keymaps")

vim.cmd("set completeopt=menu,menuone,noselect")
vim.opt.completeopt = { "menu", "menuone", "noselect" }

-- Configure LSP diagnostics
vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})

-- vim.api.nvim_create_autocmd("LspAttach", {
--   callback = function(args) vim.bo[args.buf].omnifunc = nil end,
-- })

vim.cmd(":hi statusline guibg=NONE")
