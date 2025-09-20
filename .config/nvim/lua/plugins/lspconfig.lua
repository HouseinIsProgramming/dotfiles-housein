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
            local chars = {}; for i = 32, 126 do table.insert(chars, string.char(i)) end
            ---@diagnostic disable-next-line: need-check-nil
            client.server_capabilities.completionProvider.triggerCharacters = chars

            vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
          end
        end,
      })
    end,
  },
}
