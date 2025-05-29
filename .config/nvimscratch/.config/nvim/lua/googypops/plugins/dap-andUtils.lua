return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "leoluz/nvim-dap-go",
      "rcarriga/nvim-dap-ui",
      "theHamsta/nvim-dap-virtual-text",
      "nvim-neotest/nvim-nio",
      "williamboman/mason.nvim",
      "mfussenegger/nvim-dap-python",
    },
    config = function()
      local dap = require("dap")
      local ui = require("dapui")

      require("dapui").setup()
      require("dap-go").setup()
      -- require("dap-python").setup("python3")
      require("dap-python").setup("~/.local/share/nvim/mason/packages/debugpy/venv/bin/python")

      require("nvim-dap-virtual-text").setup({
        -- This just tries to mitigate the chance that I leak tokens here. Probably won't stop it from happening...
        display_callback = function(variable)
          local name = string.lower(variable.name)
          local value = string.lower(variable.value)
          if name:match("secret") or name:match("api") or value:match("secret") or value:match("api") then
            return "*****"
          end

          if #variable.value > 15 then
            return " " .. string.sub(variable.value, 1, 15) .. "... "
          end

          return " " .. variable.value
        end,
      })

      -- Handled by nvim-dap-go
      -- dap.adapters.go = {
      --   type = "server",
      --   port = "${port}",
      --   executable = {
      --     command = "dlv",
      --     args = { "dap", "-l", "127.0.0.1:${port}" },
      --   },
      -- }
      --
      --
      require("dap").adapters["pwa-node"] = {
        type = "server",
        host = "localhost",
        port = "${port}",
        executable = {
          command = "node",
          args = {
            "/Users/house/.local/share/nvim/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js",
            "${port}",
          },
        },
      }

      require("dap").configurations.javascript = {
        {
          type = "pwa-node",
          request = "launch",
          name = "Launch file",
          program = "${file}", -- Launch the currently open file
          cwd = "${workspaceFolder}", -- Current working directory
          sourceMaps = true,
          protocol = "inspector",
          console = "integratedTerminal",
        },
      }

      dap.adapters.node = {
        type = "executable",
        command = "node",
        args = { vim.fn.stdpath("data") .. "/mason/packages/node-debug2-adapter/out/src/nodeDebug.js" },
      }

      dap.configurations.typescript = dap.configurations.typescript or {}
      table.insert(dap.configurations.typescript, {
        name = "Launch TypeScript",
        type = "node",
        request = "launch",
        program = "${file}",
        cwd = "${workspaceFolder}",
        sourceMaps = true,
        outFiles = { "${workspaceFolder}/**/*.js" },
        protocol = "inspector",
        console = "integratedTerminal",
      })

      -- Configure Python debugging
      -- HANDELED BY PYTHON DAP
      -- dap.adapters.debugpy = {
      --   type = "executable",
      --   command = "python",
      --   args = {
      --     vim.fn.stdpath("data") .. "/mason/packages/debugpy/mason",
      --     vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/debugpy",
      --     "--listen",
      --     "127.0.0.1:${port}",
      --   },
      -- }
      --
      -- dap.configurations.python = {
      --   {
      --     type = "debugpy",
      --     request = "launch",
      --     name = "Launch Python file",
      --     program = "${file}",
      --     cwd = "${workspaceFolder}",
      --     console = "integratedTerminal",
      --   },
      --   {
      --     type = "debugpy",
      --     request = "attach",
      --     name = "Attach to local process",
      --     connect = {
      --       host = "127.0.0.1",
      --       port = 5678, -- Default debugpy port
      --     },
      --   },
      -- }

      local elixir_ls_debugger = vim.fn.exepath("elixir-ls-debugger")
      if elixir_ls_debugger ~= "" then
        dap.adapters.mix_task = {
          type = "executable",
          command = elixir_ls_debugger,
        }

        dap.configurations.elixir = {
          {
            type = "mix_task",
            name = "phoenix server",
            task = "phx.server",
            request = "launch",
            projectDir = "${workspaceFolder}",
            exitAfterTaskReturns = false,
            debugAutoInterpretAllModules = false,
          },
        }
      end

      vim.keymap.set("n", "<space>db", dap.toggle_breakpoint)
      vim.keymap.set("n", "<space>gb", dap.run_to_cursor)

      -- Eval var under cursor
      vim.keymap.set("n", "<space>?", function()
        require("dapui").eval(nil, { enter = true })
      end)

      vim.keymap.set("n", "<leader>dc", dap.continue, { desc = "Start/continue debugging" })
      vim.keymap.set("n", "<leader>di", dap.step_into, { desc = "Step into function" })
      vim.keymap.set("n", "<leader>do", dap.step_over, { desc = "Step over function" })
      vim.keymap.set("n", "<leader>dk", dap.step_out, { desc = "Step out of function" })
      vim.keymap.set("n", "<leader>dh", dap.step_back, { desc = "Step back in execution" })
      vim.keymap.set("n", "<leader>dr", dap.restart, { desc = "Restart debugging session" })
      vim.keymap.set("n", "<leader>dp", dap.pause, { desc = "Pause debugging session" })
      vim.keymap.set("n", "<leader>du", function()
        require("dapui").toggle({ reset = true })
      end, { desc = "Toggle [U]I" })

      dap.listeners.before.attach.dapui_config = function()
        ui.open()
      end
      dap.listeners.before.launch.dapui_config = function()
        ui.open()
      end
      dap.listeners.before.event_terminated.dapui_config = function()
        ui.close()
      end
      dap.listeners.before.event_exited.dapui_config = function()
        ui.close()
      end
    end,
  },
}
