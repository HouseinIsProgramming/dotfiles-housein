-- Lua ftplugin configuration
-- This file is automatically loaded when a Lua buffer is opened

-- Check if we're in a Love2D project
local function is_love2d_project()
  local cwd = vim.fn.getcwd()
  local main_lua = cwd .. "/main.lua"
  local conf_lua = cwd .. "/conf.lua"
  
  return vim.fn.filereadable(main_lua) == 1 or vim.fn.filereadable(conf_lua) == 1
end

-- Set up Love2D keymap if in a Love2D project
if is_love2d_project() then
  vim.keymap.set("n", "<leader>lr", function()
    -- Close any existing floaterm
    vim.cmd("FloatermKill!")
    -- Run Love2D project in a new floaterm
    vim.cmd("FloatermNew --autoclose=2 love .")
  end, {
    buffer = true,
    desc = "Run Love2D project",
    silent = true,
  })
end