return {
  "ThePrimeagen/harpoon",
  cond = not vim.g.is_vscode,

  config = function()
    require("harpoon").setup({
      -- save_on_toggle = true,
    })

    -- Navigation to numbered files
    for i = 1, 9 do
      vim.keymap.set(
        "n",
        "<leader>" .. i,
        ":lua require('harpoon.ui').nav_file(" .. i .. ")<CR>",
        { silent = true, desc = "which_key_ignore" }
        -- { silent = true, desc = "Go to " .. i .. " pooned" }
      )
    end

    -- Add file to harpoon
    vim.keymap.set(
      "n",
      "<leader>m",
      ":lua require('harpoon.mark').add_file()<CR>",
      { silent = true, desc = "Add file to harpoon" }
    )

    -- Toggle harpoon menu
    vim.keymap.set(
      "n",
      "<leader>h",
      ":lua require('harpoon.ui').toggle_quick_menu()<CR>",
      { silent = true, desc = "Toggle harpoon menu" }
    )
  end,
}
