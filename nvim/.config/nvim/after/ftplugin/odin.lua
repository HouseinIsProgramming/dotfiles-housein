local opts = { buffer = true, silent = true }

-- Macros for swapping x/y
vim.fn.setreg("x", "fxry")
vim.fn.setreg("y", "fyrx")

local function run_in_term(cmd)
	vim.cmd("update")
	vim.cmd("vsplit term://" .. cmd)
	vim.cmd("startinsert")
end

-- Odin run
vim.keymap.set("n", "<leader>kr", function()
	run_in_term("odin run .")
end, vim.tbl_extend("force", opts, { desc = "Odin run" }))

-- Odin build
vim.keymap.set("n", "<leader>kb", function()
	run_in_term("odin build .")
end, vim.tbl_extend("force", opts, { desc = "Odin build" }))

-- Odin check
vim.keymap.set("n", "<leader>kc", function()
	run_in_term("odin check .")
end, vim.tbl_extend("force", opts, { desc = "Odin check" }))

-- :Make command with quickfix integration
vim.api.nvim_buf_create_user_command(0, "Make", function(o)
	vim.cmd("make! " .. o.args)
	vim.cmd("copen")
end, { nargs = "*" })

vim.opt_local.makeprg = "odin\\ build\\ ."
