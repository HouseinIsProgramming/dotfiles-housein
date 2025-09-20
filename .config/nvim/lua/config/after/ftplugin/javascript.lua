local function RunNodeFile()
  vim.cmd("split term://node " .. vim.fn.expand("%"))
  vim.cmd("tnoremap <buffer> <C-c> exit<CR>")
  vim.cmd("startinsert")
end

-- Create a unique augroup for JavaScript ftplugin settings
-- This helps manage autocommands and avoids duplicates if the file is sourced multiple times
local ft_javascript_group = vim.api.nvim_create_augroup("JavaScriptFtPlugin", { clear = true })

-- Set up the keymap for the current buffer when a JavaScript file is loaded
vim.api.nvim_create_autocmd("FileType", {
  group = ft_javascript_group,
  pattern = "javascript",
  callback = function()
    -- Keymap specifically for the current buffer (0)
    vim.api.nvim_buf_set_keymap(0, "n", "<leader>rn", ":lua " .. vim.fn.luaeval("RunNodeFile()"), { noremap = true, silent = true })
  end,
})

-- You can also place other JavaScript-specific options here
vim.opt_local.tabstop = 2
vim.opt_local.shiftwidth = 2
vim.opt_local.expandtab = true
