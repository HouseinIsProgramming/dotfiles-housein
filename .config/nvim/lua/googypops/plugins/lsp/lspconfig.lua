return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "williamboman/mason.nvim",
    "hrsh7th/cmp-nvim-lsp",
    {
      "folke/lazydev.nvim",
      ft = "lua",
      opts = { library = { { path = "${3rd}/luv/library", words = { "vim%.uv" } } } },
    },
    { "antosha417/nvim-lsp-file-operations", config = true }, -- Uncomment if you use it
    {
      "benomahony/uv.nvim",
      opts = { -- lazy.nvim passes opts to the plugin's setup function
        auto_activate_venv = true,
      },
      event = { "BufReadPre", "BufNewFile" },
    },
  },
  config = function()
    local lspconfig = require("lspconfig")
    local cmp_nvim_lsp = require("cmp_nvim_lsp")
    local keymap = vim.keymap

    local capabilities = cmp_nvim_lsp.default_capabilities()

    vim.diagnostic.config({
      virtual_text = true,
      signs = true,
      underline = true,
      update_in_insert = false,
      severity_sort = true,
    })

    local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
    for type, icon in pairs(signs) do
      local hl = "DiagnosticSign" .. type
      vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
    end

    -- Autocommand that runs when an LSP attaches to a buffer
    -- This is where you set your common keymaps for all LSPs
    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
      callback = function(ev)
        local client = vim.lsp.get_client_by_id(ev.client_id)
        local bufnr = ev.buf

        -- Standard LSP keymaps
        local opts = { buffer = bufnr, silent = true }
        opts.desc = "Show LSP references"
        keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts)
        opts.desc = "Go to declaration"
        keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
        opts.desc = "Show LSP definitions"
        keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts)
        opts.desc = "Show LSP implementations"
        keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts)
        opts.desc = "Show LSP type definitions"
        keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts)
        opts.desc = "See available code actions"
        keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)
        opts.desc = "Smart rename"
        keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
        opts.desc = "Show buffer diagnostics"
        keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts)
        opts.desc = "Show line diagnostics"
        keymap.set("n", "<C-k>", vim.diagnostic.open_float, opts) -- Some use K for hover, <leader>k for float
        opts.desc = "Go to previous diagnostic"
        keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
        opts.desc = "Go to next diagnostic"
        keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
        opts.desc = "Show documentation for what is under cursor"
        keymap.set("n", "K", vim.lsp.buf.hover, opts)
        opts.desc = "Restart LSP"
        keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts) -- Requires :LspRestart command (e.g., from lspconfig)

        -- Enable omnifunc completion
        vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

        -- Enable format on save if the client supports it
        if client and client.supports_method("textDocument/formatting") then
          vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = bufnr,
            group = vim.api.nvim_create_augroup("LspFormatOnSave_" .. bufnr, { clear = true }),
            callback = function()
              vim.lsp.buf.format({ bufnr = bufnr, async = false, timeout_ms = 2000 })
            end,
          })
        end
      end,
    })

    -- --- Individual LSP Server Configurations ---

    lspconfig.gopls.setup({
      capabilities = capabilities,
      settings = {
        gopls = {
          gofumpt = true,
          codelenses = {
            gc_details = false,
            generate = true,
            regenerate_cgo = true,
            run_govulncheck = true,
            test = true,
            tidy = true,
            upgrade_dependency = true,
            vendor = true,
          },
          hints = {
            assignVariableTypes = true,
            compositeLiteralFields = true,
            compositeLiteralTypes = true,
            constantValues = true,
            functionTypeParameters = true,
            parameterNames = true,
            rangeVariableTypes = true,
          },
          analyses = {
            nilness = true,
            unusedparams = true,
            unusedwrite = true,
            useany = true,
          },
          usePlaceholders = true,
          completeUnimported = true,
          staticcheck = true,
          directoryFilters = { "-.git", "-.vscode", "-.idea", "-.vscode-test", "-node_modules", "-.nvim" },
          semanticTokens = true,
        },
      },
    })

    -- LuaLS (for Neovim config, etc.)
    lspconfig.lua_ls.setup({
      capabilities = capabilities,
      -- on_attach is not strictly needed here if LspAttach handles all common keymaps
      -- However, if lua_ls needed specific on_attach logic, it would go here.
      settings = {
        Lua = {
          runtime = { version = "LuaJIT" },
          diagnostics = { globals = { "vim" } },
          workspace = {
            library = vim.api.nvim_get_runtime_file("", true),
            checkThirdParty = false,
          },
          completion = { callSnippet = "Replace" },
          telemetry = { enable = false },
        },
      },
    })

    -- Svelte
    lspconfig.svelte.setup({
      capabilities = capabilities,
      on_attach = function(client, bufnr)
        -- NOTE: Common keymaps are set by the LspAttach autocommand.
        -- This on_attach is for Svelte-specific logic.
        --
        vim.api.nvim_create_autocmd("BufWritePost", {
          group = vim.api.nvim_create_augroup("SvelteTsJsWatch_" .. bufnr, { clear = true }),
          pattern = { "*.js", "*.ts" }, -- Svelte LSP might need to know about JS/TS changes
          buffer = bufnr,
          callback = function(ctx)
            if client and client.is_active() then
              -- Use vim.uri_from_bufnr(ctx.buf) or construct URI as needed by Svelte LSP
              client.notify("$/onDidChangeTsOrJsFile", { uri = vim.uri_from_bufnr(ctx.buf) })
            end
          end,
        })
      end,
    })

    -- GraphQL
    lspconfig.graphql.setup({
      capabilities = capabilities,
      filetypes = { "graphql", "gql", "svelte", "typescriptreact", "javascriptreact" },
    })

    lspconfig.basedpyright.setup({
      capabilities = capabilities,
      -- on_attach not needed if LspAttach handles keymaps and no specific logic for basedpyright
      settings = {
        basedpyright = { -- Note: some LSPs might expect settings under `python` or just top-level
          analysis = {
            typeCheckingMode = "strict",
            deprecateTypingAliases = true,
            diagnosticSeverityOverrides = {
              reportDeprecated = "warning",
            },
            inlayHints = {
              variableTypes = true,
              functionReturnTypes = true,
              callArgumentNames = true,
            },
            -- Ensure basedpyright uses the uv environment
            -- It usually respects VIRTUAL_ENV automatically if uv.nvim sets it.
            -- If not, you might need to set pythonPath explicitly:
            -- pythonPath = (vim.env.VIRTUAL_ENV and (vim.env.VIRTUAL_ENV .. "/bin/python") or vim.fn.exepath("python3") or vim.fn.exepath("python")),
          },
        },
        python = { -- basedpyright might also look for pythonPath here
          pythonPath = (function()
            local venv = vim.env.VIRTUAL_ENV
            if venv and vim.fn.empty(venv) == 0 and vim.fn.isdirectory(venv) == 1 then
              local sep = vim.fn.has("win32") == 1 and "\\" or "/"
              local bin = vim.fn.has("win32") == 1 and "Scripts" or "bin"
              local pexe = venv .. sep .. bin .. sep .. "python"
              if vim.fn.has("win32") == 1 then
                pexe = pexe .. ".exe"
              end
              if vim.fn.filereadable(pexe) == 1 then
                return pexe
              end
            end
            return vim.fn.exepath("python3") or vim.fn.exepath("python")
          end)(),
        },
      },
      filetypes = { "python" },
    })

    -- lspconfig.pyright.setup({
    --   capabilities = capabilities,
    --   settings = {
    --     python = {
    --       pythonPath = (function()
    --         local venv = vim.env.VIRTUAL_ENV
    --         if venv and vim.fn.empty(venv) == 0 and vim.fn.isdirectory(venv) == 1 then
    --           local sep = vim.fn.has("win32") == 1 and "\\" or "/"
    --           local bin = vim.fn.has("win32") == 1 and "Scripts" or "bin"
    --           local pexe = venv .. sep .. bin .. sep .. "python"
    --           if vim.fn.has("win32") == 1 then pexe = pexe .. ".exe" end
    --           if vim.fn.filereadable(pexe) == 1 then return pexe end
    --         end
    --         return vim.fn.exepath("python3") or vim.fn.exepath("python")
    --       end)(),
    --       analysis = {
    --         autoSearchPaths = true,
    --         useLibraryCodeForTypes = true,
    --         diagnosticMode = "workspace",
    --         typeCheckingMode = "basic", -- or "strict"
    --       },
    --     },
    --   },
    --   filetypes = { "python" },
    -- })

    -- lspconfig.ruff.setup({
    --   capabilities = capabilities,
    --   -- init_options can be used for ruff-specific settings if needed
    --   filetypes = { "python" },
    -- })

    -- EmmetLS
    local disableEmmet = true -- Set to false to enable
    if not disableEmmet then
      lspconfig.emmet_ls.setup({
        capabilities = capabilities,
        filetypes = { "html", "typescriptreact", "javascriptreact", "css", "sass", "scss", "less", "svelte" },
      })
    end

    -- VTSLS (TypeScript/JavaScript)
    lspconfig.vtsls.setup({
      capabilities = capabilities,
      settings = {
        typescript = {
          inlayHints = {
            parameterNames = { enabled = "all" }, -- "literals", "none"
            parameterTypes = { enabled = true },
            variableTypes = { enabled = true },
            propertyDeclarationTypes = { enabled = true },
            functionLikeReturnTypes = { enabled = true },
            enumMemberValues = { enabled = true },
          },
        },
        javascript = {
          inlayHints = {
            parameterNames = { enabled = "all" },
            parameterTypes = { enabled = true },
            variableTypes = { enabled = true },
            propertyDeclarationTypes = { enabled = true },
            functionLikeReturnTypes = { enabled = true },
            enumMemberValues = { enabled = true },
          },
        },
      },
    })
  end,
}
