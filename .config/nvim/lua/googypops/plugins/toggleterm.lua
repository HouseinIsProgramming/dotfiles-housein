return {
  "akinsho/toggleterm.nvim",
  config = function()
    require("toggleterm").setup({
      direction = "float",
      open_mapping = "<D-j>",
      start_in_insert = true, -- Optional: Start in insert mode for immediate typing
    })

    -- No need for extra keymap definition if you're using open_mapping
  end,
}
