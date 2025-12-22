vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.g.base46_cache = vim.fn.stdpath "data" .. "/base46/"

require("config.lazy")
require("config.options")
require("config.keymaps")
require("config.autocmds")
