return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "mason.nvim",
    "mason-lspconfig.nvim",
  },
  config = function()
    local lspconfig = require("lspconfig")
    
    local capabilities = require("blink.cmp").get_lsp_capabilities()
    
    local on_attach = function(client, bufnr)
      local opts = { buffer = bufnr, silent = true }
      
      vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
      vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
      vim.keymap.set("n", "gI", vim.lsp.buf.implementation, opts)
      vim.keymap.set("n", "gy", vim.lsp.buf.type_definition, opts)
      vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
      vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
      vim.keymap.set("n", "gK", vim.lsp.buf.signature_help, opts)
      vim.keymap.set("i", "<C-k>", vim.lsp.buf.signature_help, opts)
      vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
      vim.keymap.set("n", "<leader>cr", vim.lsp.buf.rename, opts)
    end
    
    lspconfig.lua_ls.setup({
      capabilities = capabilities,
      on_attach = on_attach,
      settings = {
        Lua = {
          completion = {
            callSnippet = "Replace",
          },
          diagnostics = {
            globals = { "vim" },
          },
          workspace = {
            library = {
              vim.env.VIMRUNTIME,
              "${3rd}/luv/library",
            },
          },
        },
      },
    })
  end,
}