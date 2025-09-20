-- Rust-specific keymaps for Make commands
local opts = { buffer = true, silent = true }

-- Make run
vim.keymap.set('n', '<leader>kr', ':make run<CR>', vim.tbl_extend('force', opts, { desc = 'Make run' }))

-- Make build
vim.keymap.set('n', '<leader>kb', ':make build<CR>', vim.tbl_extend('force', opts, { desc = 'Make build' }))

-- Make bench
vim.keymap.set('n', '<leader>kB', ':make bench<CR>', vim.tbl_extend('force', opts, { desc = 'Make bench' }))

-- Make test
vim.keymap.set('n', '<leader>kt', ':make test<CR>', vim.tbl_extend('force', opts, { desc = 'Make test' }))

-- Make check
vim.keymap.set('n', '<leader>kc', ':make check<CR>', vim.tbl_extend('force', opts, { desc = 'Make check' }))

-- Make doc
vim.keymap.set('n', '<leader>kd', ':make doc<CR>', vim.tbl_extend('force', opts, { desc = 'Make doc build' }))