-- Go-specific keymaps for Go CLI commands
local opts = { buffer = true, silent = true }

-- Go run
vim.keymap.set('n', '<leader>kr', ':!go run .<CR>', vim.tbl_extend('force', opts, { desc = 'Go run' }))

-- Go build
vim.keymap.set('n', '<leader>kb', ':!go build<CR>', vim.tbl_extend('force', opts, { desc = 'Go build' }))

-- Go test
vim.keymap.set('n', '<leader>kt', ':!go test<CR>', vim.tbl_extend('force', opts, { desc = 'Go test' }))

-- Go test with benchmarks
vim.keymap.set('n', '<leader>kB', ':!go test -bench=.<CR>', vim.tbl_extend('force', opts, { desc = 'Go bench' }))

-- Go vet (static analysis)
vim.keymap.set('n', '<leader>kv', ':!go vet<CR>', vim.tbl_extend('force', opts, { desc = 'Go vet' }))

-- Go fmt (format code)
vim.keymap.set('n', '<leader>kf', ':!go fmt<CR>', vim.tbl_extend('force', opts, { desc = 'Go fmt' }))

-- Go mod tidy
vim.keymap.set('n', '<leader>km', ':!go mod tidy<CR>', vim.tbl_extend('force', opts, { desc = 'Go mod tidy' }))
