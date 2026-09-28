-- TypeScript ftplugin configuration
-- This file is automatically loaded when a TypeScript buffer is opened

local function RunBunFile()
  vim.cmd("split term://bun run " .. vim.fn.expand("%"))
  vim.cmd("tnoremap <buffer> <C-c> exit<CR>")
  vim.cmd("startinsert")
end

-- TypeScript-specific keymaps using Bun
local opts = { buffer = true, silent = true }

-- Bun run current file
vim.keymap.set('n', '<leader>kr', RunBunFile, vim.tbl_extend('force', opts, { desc = 'Run current TypeScript file with Bun' }))

-- Bun test
vim.keymap.set('n', '<leader>kt', ':split term://bun test<CR>:startinsert<CR>', vim.tbl_extend('force', opts, { desc = 'Run Bun tests' }))

-- Bun install
vim.keymap.set('n', '<leader>ki', ':split term://bun install<CR>:startinsert<CR>', vim.tbl_extend('force', opts, { desc = 'Bun install dependencies' }))

-- Bun build
vim.keymap.set('n', '<leader>kb', ':split term://bun build<CR>:startinsert<CR>', vim.tbl_extend('force', opts, { desc = 'Bun build project' }))

-- Bun check (type checking)
vim.keymap.set('n', '<leader>kc', ':split term://bun --bun tsc --noEmit<CR>:startinsert<CR>', vim.tbl_extend('force', opts, { desc = 'TypeScript type check' }))

-- Bun dev (if package.json has dev script)
vim.keymap.set('n', '<leader>kd', ':split term://bun run dev<CR>:startinsert<CR>', vim.tbl_extend('force', opts, { desc = 'Run dev script with Bun' }))

-- Bun lint (if package.json has lint script)
vim.keymap.set('n', '<leader>kl', ':split term://bun run lint<CR>:startinsert<CR>', vim.tbl_extend('force', opts, { desc = 'Run lint script with Bun' }))

-- TypeScript-specific settings
vim.opt_local.tabstop = 2
vim.opt_local.shiftwidth = 2
vim.opt_local.expandtab = true