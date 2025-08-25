return {
  "ThePrimeagen/harpoon",

  config = function()
    require("harpoon").setup({
      -- save_on_toggle = true,
    })
    for i = 1, 9 do
      vim.keymap.set("n", "<leader>" .. i, ":lua require('harpoon.ui').nav_file(" .. i .. ")<CR>", { silent = true })
    end
    vim.keymap.set("n", "<leader>1", ":lua require('harpoon.ui').nav_file(1)<CR>", { silent = true })
  end,

  vim.keymap.set("n", "<leader>m", ":lua require('harpoon.mark').add_file()<CR>"),
  vim.keymap.set("n", "<leader>h", ":lua require('harpoon.ui').toggle_quick_menu()<CR>"),
}
