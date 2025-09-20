-- JavaScript ftplugin configuration
-- This file is automatically loaded when a JavaScript buffer is opened

local function RunNodeFile()
  vim.cmd("split term://node " .. vim.fn.expand("%"))
  vim.cmd("tnoremap <buffer> <C-c> exit<CR>")
  vim.cmd("startinsert")
end

-- Set up keymap for the current buffer
vim.keymap.set("n", "<leader>rn", RunNodeFile, { 
  buffer = true, 
  noremap = true, 
  silent = true,
  desc = "Run current JavaScript file with Node.js"
})

-- JavaScript-specific settings
vim.opt_local.tabstop = 2
vim.opt_local.shiftwidth = 2
vim.opt_local.expandtab = true