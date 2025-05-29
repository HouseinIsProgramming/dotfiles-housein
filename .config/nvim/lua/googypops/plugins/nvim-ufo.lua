return {
  "kevinhwang91/nvim-ufo",
  event = "BufReadPost",
  dependencies = "kevinhwang91/promise-async",
  config = function()
    vim.o.foldcolumn = "0" -- show fold column
    vim.o.foldlevel = 99 -- allow all folds open by default
    vim.o.foldlevelstart = 99
    vim.o.foldenable = true -- enable folding

    local view_group = vim.api.nvim_create_augroup("auto_view", { clear = true })
    vim.api.nvim_create_autocmd({ "BufWinLeave", "BufWritePost", "WinLeave" }, {
      desc = "Save view with mkview for real files",
      group = view_group,
      callback = function(args)
        if vim.b[args.buf].view_activated then
          vim.cmd.mkview { mods = { emsg_silent = true } }
        end
      end,
    })
    vim.api.nvim_create_autocmd("BufWinEnter", {
      desc = "Try to load file view if available and enable view saving for real files",
      group = view_group,
      callback = function(args)
        if not vim.b[args.buf].view_activated then
          local filetype = vim.api.nvim_get_option_value("filetype", { buf = args.buf })
          local buftype = vim.api.nvim_get_option_value("buftype", { buf = args.buf })
          local ignore_filetypes = { "gitcommit", "gitrebase", "svg", "hgcommit" }
          if buftype == "" and filetype and filetype ~= "" and not vim.tbl_contains(ignore_filetypes, filetype) then
            vim.b[args.buf].view_activated = true
            vim.cmd.loadview { mods = { emsg_silent = true } }
          end
        end
      end,
    })

    -- Set keymaps
    vim.keymap.set("n", "zR", require("ufo").openAllFolds, { desc = "Open all folds" })
    vim.keymap.set("n", "zM", require("ufo").closeAllFolds, { desc = "Close all folds" })
    vim.keymap.set("n", "zK", function()
      local winid = require("ufo").peekFoldedLinesUnderCursor()
      if not winid then
        vim.lsp.buf.hover()
      end
    end, { desc = "Peek fold or hover" })
    vim.keymap.set("n", "zf", function()
      vim.cmd.normal "za"
    end, { desc = "Toggle fold under cursor", silent = true })

    -- Properly call ufo setup and pass the provider_selector here
    require("ufo").setup {
      provider_selector = function(bufnr, filetype, buftype)
        return { "lsp", "indent" }
      end,
    }
  end,
}
