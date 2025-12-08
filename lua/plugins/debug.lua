return {
  -- Debug Adapter Protocol client
  {
    "mfussenegger/nvim-dap",
    event = "VeryLazy",
    keys = {
      {
        -- Continue: Shift-F5 -> c
        "<S-F5>",
        function()
          require("dap").continue()
        end,
      },
      {
        -- Stop(Quit): Shift-F4 -> q
        "<S-F4>",
        function()
          require("dap").terminate()
        end,
      },
      {
        -- BreakpoiShift-F9 -> b
        "<S-F9>",
        function()
          require("dap").toggle_breakpoint()
        end,
      },
      {
        -- StepOver(Next): Shift-F10 -> n
        "<S-F10>",
        function()
          require("dap").step_over()
        end,
      },
      {
        -- StepIn(Step): Shift-F11 -> i/s
        "<S-F11>",
        function()
          require("dap").step_into()
        end,
      },
      {
        -- StepOut(Return): Shift-F2 -> o/r
        "<S-F2>",
        function()
          require("dap").step_out()
        end,
      },
      {
        -- List variables: Shift-F3
        "<S-F3>",
        "<cmd>Telescope dap variables<cr>",
      },
      {
        -- Test method -> <Leader>tm
        "<Leader>tm",
        function()
          require("dap-python").test_method()
        end,
      },
    },
  },

  -- UI for nvim-dap
  {
    "rcarriga/nvim-dap-ui",
    dependencies = {
      "mfussenegger/nvim-dap",
      "nvim-neotest/nvim-nio",
      "theHamsta/nvim-dap-virtual-text",
    },
    event = "VeryLazy",
    ft = {
      "python",
      "python3",
    },
    keys = {
      {
        -- Toggle debugger Shift-F12 -> d
        "<S-F12>",
        function()
          require("dapui").toggle()
        end,
      },
    },
    config = function()
      local dap, dapui = require "dap", require "dapui"
      -- setup
      dapui.setup()
      -- open and close windows automatically
      dap.listeners.before.attach.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.launch.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated.dapui_config = function()
        dapui.close()
      end
      dap.listeners.before.event_exited.dapui_config = function()
        dapui.close()
      end
      require("nvim-dap-virtual-text").setup()
      -- icons
      vim.fn.sign_define("DapBreakpoint", { text = "⛔", texthl = "", linehl = "", numhl = "" })
      vim.fn.sign_define("DapStopped", { text = "👉", texthl = "", linehl = "", numhl = "" })
    end,
  },
  -- lua debugger
  {
    "tomblind/local-lua-debugger-vscode",
    dependencies = {
      "mfussenegger/nvim-dap",
      "rcarriga/nvim-dap-ui",
    },
    event = "VeryLazy",
    ft = {
      "lua",
    },
    config = function()
      local dap = require "dap"
      dap.configurations.lua = {
        {
          name = "Current file (local-lua-dbg, lua)",
          type = "local-lua",
          request = "launch",
          cwd = "${workspaceFolder}",
          program = {
            lua = "lua5.1",
            file = "${file}",
          },
          args = {},
        },
      }
    end,
  },
  -- python debugger
  {
    "mfussenegger/nvim-dap-python",
    dependencies = {
      "mfussenegger/nvim-dap",
      "rcarriga/nvim-dap-ui",
    },
    event = "VeryLazy",
    ft = {
      "python",
      "python3",
    },
    config = function()
      require("dap-python").setup(
        string.format("%s/dotfiles/.venv/bin/python", vim.api.nvim_eval "$HOME")
      )
      require("dap-python").test_runner = "pytest"
      local dap = require "dap"
      dap.adapters.python = {
        type = "executable",
        command = string.format("%s/dotfiles/.venv/bin/python", vim.api.nvim_eval "$HOME"),
        args = { "-m", "debugpy.adapter" },
      }
      dap.configurations.python = {
        {
          type = "python",
          request = "launch",
          name = "Python launch configurations",
          program = "${file}",
        },
      }
      vim.api.nvim_set_keymap(
        "n",
        "<Leader>tm",
        ":lua require('dap-python').test_method()<CR>",
        { noremap = true, silent = true }
      )
    end,
  },
}
