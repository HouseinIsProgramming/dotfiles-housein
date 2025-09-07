-- vim.api.nvim_create_autocmd("LspAttach", {
-- 	callback = function(ev)
-- 		local client = vim.lsp.get_client_by_id(ev.data.client_id)
-- 		if client:supports_method("textDocument/completion") then
-- 			vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
-- 		end
-- 	end,
-- })

vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("highlight_yank", {}),
  desc = "Hightlight selection on yank",
  pattern = "*",
  callback = function() vim.highlight.on_yank({ higroup = "IncSearch", timeout = 300 }) end,
})

vim.api.nvim_create_autocmd("BufReadPost", {
  group = vim.api.nvim_create_augroup("RememberCursorPosition", { clear = true }),
  callback = function()
    -- Only jump if the mark exists, is not the first line (often default),
    -- and is within the file's current bounds.
    if vim.fn.line("'\"'") > 1 and vim.fn.line("'\"'") <= vim.fn.line("$") then vim.cmd('normal! g`"') end
  end,
})

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

local view_group = augroup("auto_view", { clear = true })
autocmd({ "BufWinLeave", "BufWritePost", "WinLeave" }, {
  desc = "Save view with mkview for real files",
  group = view_group,
  callback = function(args)
    if vim.b[args.buf].view_activated then vim.cmd.mkview({ mods = { emsg_silent = true } }) end
  end,
})
autocmd("BufWinEnter", {
  desc = "Try to load file view if available and enable view saving for real files",
  group = view_group,
  callback = function(args)
    if not vim.b[args.buf].view_activated then
      local filetype = vim.api.nvim_get_option_value("filetype", { buf = args.buf })
      local buftype = vim.api.nvim_get_option_value("buftype", { buf = args.buf })
      local ignore_filetypes = { "gitcommit", "gitrebase", "svg", "hgcommit" }
      if buftype == "" and filetype and filetype ~= "" and not vim.tbl_contains(ignore_filetypes, filetype) then
        vim.b[args.buf].view_activated = true
        vim.cmd.loadview({ mods = { emsg_silent = true } })
      end
    end
  end,
})

-- Love2D project detection and keymap setup
local love_group = augroup("love2d_project", { clear = true })
autocmd({ "BufEnter", "DirChanged" }, {
  desc = "Detect Love2D project and setup run keymap",
  group = love_group,
  callback = function()
    local cwd = vim.fn.getcwd()
    local main_lua = cwd .. "/main.lua"
    local conf_lua = cwd .. "/conf.lua"
    
    -- Check if it's a Love2D project (has main.lua or conf.lua)
    if vim.fn.filereadable(main_lua) == 1 or vim.fn.filereadable(conf_lua) == 1 then
      -- Set up the keymap for this buffer
      vim.keymap.set("n", "<leader>lr", function()
        -- Close any existing floaterm
        vim.cmd("FloatermKill!")
        -- Run Love2D project in a new floaterm
        vim.cmd("FloatermNew --autoclose=2 love .")
      end, { 
        buffer = true, 
        desc = "Run Love2D project",
        silent = true 
      })
    else
      -- Remove the keymap if not in a Love2D project
      pcall(vim.keymap.del, "n", "<leader>lr", { buffer = true })
    end
  end,
})
