vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- VSCode detection (MUST be before lazy.nvim loads plugins)
vim.g.is_vscode = vim.g.vscode ~= nil

require("config.lazy")
require("config.options")
require("config.keymaps")
require("config.autocmds")
