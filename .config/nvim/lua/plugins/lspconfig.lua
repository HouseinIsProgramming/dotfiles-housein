---@diagnostic disable: param-type-not-match
return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",
      {
        "folke/lazydev.nvim",
        ft = "lua",
        opts = {
          library = {
            { path = "${3rd}/luv/library", words = { "vim%.uv" } },
          },
        },
      },
    },
    config = function()
      require("mason").setup()
      ---@diagnostic disable-next-line: missing-fields
      require("mason-lspconfig").setup({
        ensure_installed = {
          "emmylua_ls",
          "vtsls",
          "rust_analyzer",
          "gopls"
        },
      })
      require("mason-tool-installer").setup({
        ensure_installed = {
          "stylua",
          "selene",
          "prettier",
          "prettierd",
        },
      })


      vim.keymap.set("n", "<leader>lf", function() vim.lsp.buf.format() end)
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('my.lsp', {}),
        callback = function(args)
          local client = assert(vim.lsp.get_client_by_id(args.data.client_id))

          -- Enable auto-completion. Note: Use CTRL-Y to select an item. |complete_CTRL-Y|
          if client:supports_method('textDocument/completion') then
            -- Optional: trigger autocompletion on EVERY keypress. May be slow!
            vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = false })
          end

          local opts = { buffer = args.buf }

          -- Open the diagnostic under the cursor in a float window
          vim.keymap.set("n", "<leader>d", function()
            vim.diagnostic.open_float({
              border = "single",
            })
          end, opts)

          vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
          -- Source actions keymap
          vim.keymap.set(
            "n",
            "<leader>ls",
            function()
              vim.lsp.buf.code_action({
                context = {
                  only = { "source" }, -- Request all "source" actions
                  diagnostics = {},
                },
              })
            end,
            opts
          )
          
          -- Attach navic if the server supports document symbols
          if client:supports_method('textDocument/documentSymbol') then
            local navic_ok, navic = pcall(require, "nvim-navic")
            if navic_ok then
              navic.attach(client, args.buf)
            end
          end
          
          if not client:supports_method('textDocument/willSaveWaitUntil')
              and client:supports_method('textDocument/formatting') then
            vim.api.nvim_create_autocmd('BufWritePre', {
              group = vim.api.nvim_create_augroup('my.lsp', { clear = false }),
              buffer = args.buf,
              callback = function()
                vim.lsp.buf.format({ bufnr = args.buf, id = client.id, timeout_ms = 1000 })
              end,
            })
          end
        end,
      })
    end,
  },
}
