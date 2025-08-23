return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "mason.nvim",
    "mason-lspconfig.nvim",
    "schemastore.nvim",
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

    -- Lua
    lspconfig.lua_ls.setup({
      capabilities = capabilities,
      on_attach = on_attach,
      settings = {
        Lua = {
          completion = {
            callSnippet = "Replace",
          },
          diagnostics = {
            globals = { "vim", "love", "self" },
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

    -- TypeScript/JavaScript
    lspconfig.ts_ls.setup({
      capabilities = capabilities,
      on_attach = on_attach,
      settings = {
        typescript = {
          inlayHints = {
            includeInlayParameterNameHints = "literal",
            includeInlayParameterNameHintsWhenArgumentMatchesName = false,
            includeInlayFunctionParameterTypeHints = true,
            includeInlayVariableTypeHints = false,
            includeInlayPropertyDeclarationTypeHints = true,
            includeInlayFunctionLikeReturnTypeHints = true,
            includeInlayEnumMemberValueHints = true,
          },
        },
      },
    })

    -- HTML
    lspconfig.html.setup({
      capabilities = capabilities,
      on_attach = on_attach,
    })

    -- CSS
    lspconfig.cssls.setup({
      capabilities = capabilities,
      on_attach = on_attach,
    })

    -- JSON
    lspconfig.jsonls.setup({
      capabilities = capabilities,
      on_attach = on_attach,
      settings = {
        json = {
          schemas = require("schemastore").json.schemas(),
          validate = { enable = true },
        },
      },
    })

    -- ESLint
    lspconfig.eslint.setup({
      capabilities = capabilities,
      on_attach = on_attach,
      settings = {
        codeAction = {
          disableRuleComment = {
            enable = true,
            location = "separateLine",
          },
          showDocumentation = {
            enable = true,
          },
        },
        codeActionOnSave = {
          enable = false,
          mode = "all",
        },
        format = true,
        nodePath = "",
        onIgnoredFiles = "off",
        packageManager = "npm",
        quiet = false,
        rulesCustomizations = {},
        run = "onType",
        useESLintClass = false,
        validate = "on",
        workingDirectory = { mode = "location" },
      },
    })

    -- Tailwind CSS
    lspconfig.tailwindcss.setup({
      capabilities = capabilities,
      on_attach = on_attach,
    })

    -- Emmet
    lspconfig.emmet_ls.setup({
      capabilities = capabilities,
      on_attach = on_attach,
      filetypes = { "html", "css", "scss", "javascript", "javascriptreact", "typescript", "typescriptreact" },
    })

    -- TOML
    lspconfig.taplo.setup({
      capabilities = capabilities,
      on_attach = on_attach,
    })

    -- Markdown
    lspconfig.marksman.setup({
      capabilities = capabilities,
      on_attach = on_attach,
    })
  end,
}

