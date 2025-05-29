vim.g.mapleader = " "

local keymap = vim.keymap -- for conciseness

vim.keymap.set("n", "<Esc>", "<Esc>:noh<CR>", { silent = true, noremap = true })

-- increment/decrement numbers
keymap.set("n", "<leader>+", "<C-a>", { desc = "Increment number" }) -- increment
keymap.set("n", "<leader>-", "<C-x>", { desc = "Decrement number" }) -- decrement

-- window management
keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" }) -- split window vertically
keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" }) -- split window horizontally
keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" }) -- make split windows equal width & height
keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" }) -- close current split window

-- keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open new tab" }) -- open new tab
-- keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close current tab" }) -- close current tab
keymap.set("n", "<Tab>", "<cmd>BufferNext<CR>", { desc = "Go to next tab" }) --  go to next tab
keymap.set("n", "<S-Tab>", "<cmd>BufferPrevious<CR>", { desc = "Go to previous tab" }) --  go to previous tab
keymap.set("n", "<leader>bp", "<cmd>BufferPick<CR>", { desc = "Go to previous tab" }) --  go to previous tab
keymap.set("n", "<leader>bo", "<cmd>BufferCloseAllButCurrentOrPinned<CR>", { desc = "Close all Other buffers" }) --  go to previous tab
keymap.set("n", "<leader><Tab>", "<cmd>BufferPin<CR>", { desc = "Pin Buffer" }) --  go to previous tab
keymap.set("n", "<leader>1", "<cmd>BufferGoto 1<CR>", { desc = "Go to b1" }) --  go to previous tab
keymap.set("n", "<leader>2", "<cmd>BufferGoto 2<CR>", { desc = "Go to b2" }) --  go to previous tab
keymap.set("n", "<leader>3", "<cmd>BufferGoto 3<CR>", { desc = "Go to b3" }) --  go to previous tab

keymap.set("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "Open current buffer in new tab" }) --  move current buffer to new tab

keymap.set({ "n", "i", "v" }, "<D-s>", "<cmd> w <cr>")

keymap.set("n", "<C-d>", "zz<C-d>zz", { noremap = true, silent = true })
keymap.set("n", "<C-u>", "zz<C-u>zz", { noremap = true, silent = true })

keymap.set({ "n", "i" }, "<D-s>", "<CMD>w<CR>", { desc = "save buffer" })

-- keymap.set('n', 'y a g', '<CMD>%y+<CR>', { desc = 'copy file' })
keymap.set("n", "yag", ":silent %y+<CR>", { desc = "Copy entire file to system clipboard" })

keymap.set("n", "n", "nzzzv")
keymap.set("n", "N", "Nzzzv")

-- vertical navigation fix for softwrap
keymap.set("n", "j", "gj")
keymap.set("n", "k", "gk")

keymap.set("i", "<C-a>", "<Left>", { desc = "Move cursor left in insert mode" })
keymap.set("i", "<C-f>", "<Right>", { desc = "Move cursor right in insert mode" })

-- indetation while moving in Visual
keymap.set("v", "J", ":m '>+1<CR>gv=gv")
keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Void x
keymap.set({ "n", "v" }, "x", '"_x')

-- Void shift D
keymap.set({ "n", "v" }, "<S-d>", '"_d')

keymap.set({ "v", "n" }, "<C-o>", function()
  -- In visual mode, expand the selection
  require("nvim-treesitter.incremental_selection").node_incremental()
end, { desc = "Expand Treesitter selection" })

keymap.set({ "v", "n" }, "<C-i>", function()
  require("nvim-treesitter.incremental_selection").node_decremental()
end, { desc = "Shrink Treesitter selection" })

keymap.set("n", "<leader>tw", "<CMD>set wrap!<CR>", { desc = "Toggle word wrap" })
keymap.set(
  "n",
  "<leader>th",
  "<CMD>lua vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())<CR>",
  { desc = "Toggle InlayHints" }
)

keymap.set("n", "<leader>tv", function()
  local cfg = vim.diagnostic.config()
  local use_virtual_lines = not cfg.virtual_lines
  vim.diagnostic.config({
    virtual_lines = use_virtual_lines,
    virtual_text = not use_virtual_lines,
  })
  vim.notify("Diagnostics: using " .. (use_virtual_lines and "virtual lines" or "virtual text"), vim.log.levels.INFO)
end, { desc = "Toggle diagnostic virtual lines/text" })

keymap.set("n", "<leader>xx", function()
  for _, client in ipairs(vim.lsp.get_clients()) do
    require("workspace-diagnostics").populate_workspace_diagnostics(client, 0)
  end
end, { desc = "Load all diagnostics" })
