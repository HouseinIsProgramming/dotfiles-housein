return {
  "stevearc/conform.nvim",
  opts = {},
  config = function()
    require("conform").setup({
      formatters_by_ft = {
        lua = { "stylua" },
        python = { "isort", "black" },
        rust = { "rustfmt", lsp_format = "fallback" },
        javascript = { "prettierd", "prettier", stop_after_first = true },
        typescript = { "prettierd", "prettier", stop_after_first = true },
        javascriptreact = { "prettierd", "prettier", stop_after_first = true },
        typescriptreact = { "prettierd", "prettier", stop_after_first = true },
        go = { "gofmt", lsp_format = "fallback" },
        sh = { "shfmt" },
        json = { "jq" },
        html = { "prettier", lsp_format = "fallback" },
        css = { "prettier", lsp_format = "fallback" },
        markdown = { "prettier", lsp_format = "fallback" },
        yaml = { "prettier", lsp_format = "fallback" },
        toml = { "prettier", lsp_format = "fallback" },
      },
      format_on_save = {
        -- These options will be passed to conform.format()
        timeout_ms = 500,
        lsp_format = "fallback",
      },
    })

    vim.keymap.set("n", "<leader>lf", function()
      vim.cmd("Format") -- Runs the user command "Format"
    end, { desc = "Format current file/selection" })
    vim.api.nvim_create_user_command("Format", function(args)
      local range = nil
      if args.count ~= -1 then
        local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
        range = {
          start = { args.line1, 0 },
          ["end"] = { args.line2, end_line:len() },
        }
      end
      require("conform").format({ async = true, lsp_format = "fallback", range = range }, function(err)
        if err then
          vim.notify("Format failed: " .. err, vim.log.levels.ERROR)
        else
          local formatters = require("conform").list_formatters(0)
          if #formatters > 0 then
            local names = {}
            for _, f in ipairs(formatters) do
              table.insert(names, f.name)
            end
            vim.notify("Formatted with: " .. table.concat(names, ", "), vim.log.levels.INFO)
          else
            vim.notify("Formatted with: LSP fallback", vim.log.levels.WARN)
          end
        end
      end)
    end, { range = true })
  end,
}
