return {
  "supermaven-inc/supermaven-nvim",
  config = function()
    require("supermaven-nvim").setup({
      keymaps = {
        accept_suggestion = "<C-e>",
        clear_suggestion = "<C-]>",
        accept_word = "<C-j>",
      },
    })

    -- vim.cmd("SupermavenStop")
    -- vim.cmd("SupermavenStart")

    -- Custom commands
    vim.api.nvim_create_user_command("SupermavenEnable", function()
      vim.cmd("SupermavenStart")
      print("Supermaven enabled")
    end, { desc = "Enable Supermaven" })

    vim.api.nvim_create_user_command("SupermavenDisable", function()
      vim.cmd("SupermavenStop")
      print("Supermaven disabled")
    end, { desc = "Disable Supermaven" })

    -- Key mappings
    vim.keymap.set("n", "<leader>li", function()
      vim.cmd("SupermavenToggle")
      local is_running = require("supermaven-nvim.api").is_running()
      ---@diagnostic disable-next-line: unnecessary-if
      if is_running then
        vim.notify("Supermaven is running", vim.log.levels.INFO, { title = "supermaven" })
      else
        vim.notify("Supermaven is not running", vim.log.levels.INFO, { title = "supermaven" })
      end
    end, { desc = "Toggle Supermaven" })

    vim.keymap.set("n", "<leader>le", function()
      vim.cmd("SupermavenEnable")
    end, { desc = "Enable Supermaven" })

    vim.keymap.set("n", "<leader>ld", function()
      vim.cmd("SupermavenDisable")
    end, { desc = "Disable Supermaven" })
  end,
}
