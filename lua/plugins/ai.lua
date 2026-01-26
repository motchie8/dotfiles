return {
    -- Copilot(Lua)
    {
        "zbirenbaum/copilot.lua",
        event = "InsertEnter",
        opts = {
            suggestion = {
                enabled = true,
                auto_trigger = true,
                keymap = {
                    accept = "<Tab>",
                    next = "<C-j>",
                    prev = "<C-k>",
                },
            },
            panel = { enabled = true },
            filetypes = {
                yaml = true,
                markdown = true,
                gitcommit = true,
                gitrebase = true,
            },
            -- for agentic.nvim
            should_attach = function(bufnr, bufname)
                local filetype = vim.bo[bufnr].filetype

                if filetype == "AgenticInput" then
                    return true
                end

                -- Delegate to default behavior for all other buffers
                local default_should_attach = require("copilot.config.should_attach").default
                return default_should_attach(bufnr, bufname)
            end,
        },
    },
    -- For Claude Code and Cursor CLI agentic.nvim
    {
        "carlos-algms/agentic.nvim",
        config = function()
            local use_claude_code = os.getenv("USE_CLAUDE_CODE") or "0"
            local use_cursor_cli = os.getenv("USE_CURSOR_CLI") or "0"
            local acp_providers = {
                ["claude-acp"] = {
                    default_mode = "plan",
                },
                ["cursor-acp"] = {
                    default_mode = "plan",
                },
            }
            local hooks = {
                -- Called when the user submits a prompt
                on_prompt_submit = function(data)
                    -- data.prompt: string - The user's prompt text
                    -- data.session_id: string - The ACP session ID
                    -- data.tab_page_id: number - The Neovim tabpage ID
                    vim.notify("Prompt submitted: " .. data.prompt:sub(1, 50))
                end,

                -- Called when the agent finishes responding
                on_response_complete = function(data)
                    -- data.session_id: string - The ACP session ID
                    -- data.tab_page_id: number - The Neovim tabpage ID
                    -- data.success: boolean - Whether response completed without error
                    -- data.error: table|nil - Error details if failed
                    if data.success then
                        vim.notify("Agent finished!", vim.log.levels.INFO)
                    else
                        vim.notify("Agent error: " .. vim.inspect(data.error), vim.log.levels.ERROR)
                    end
                end,
            }
            if use_claude_code == "1" then
                require("agentic").setup({
                    provider = "claude-acp",
                    acp_providers = acp_providers,
                    hooks = hooks,
                })
            elseif use_cursor_cli == "1" then
                require("agentic").setup({
                    provider = "cursor-acp",
                    acp_providers = acp_providers,
                    hooks = hooks,
                })
            else
                print(
                    "Both USE_CLAUDE_CODE and USE_CURSOR_CLI are not set to 1. Please set one of them."
                )
            end
        end,
        -- these are just suggested keymaps; customize as desired
        keys = {
            {
                "<Leader>c",
                function()
                    require("agentic").toggle()
                end,
                mode = { "n" },
                desc = "Toggle Agentic Chat",
            },
            {
                "<Leader>a",
                function()
                    require("agentic").add_selection_or_file_to_context()
                end,
                mode = { "n", "v" },
                desc = "Add file or selection to Agentic to Context",
            },
            {
                "<Leader>C",
                function()
                    require("agentic").new_session()
                end,
                mode = { "n" },
                desc = "New Agentic Session",
            },
        },
    },
    -- For Claude Code, Cursor CLI and Gemini CLI by toggleterm.nvim
    -- {
    --     "coder/claudecode.nvim",
    --     dependencies = { "folke/snacks.nvim", "akinsho/toggleterm.nvim" },
    --     keys = {
    --         { "<leader>c", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
    --     },
    --     config = function()
    --         require("claudecode").setup({})
    --         -- Key mappings for Gemini CLI
    --         local Terminal = require("toggleterm.terminal").Terminal
    --         local function toggle_gemini_cli_term()
    --             local gemini_cli_term = Terminal:new({
    --                 cmd = "gemini",
    --                 name = "Gemini CLI",
    --                 dir = "git_dir",
    --                 direction = "vertical",
    --                 shade_terminals = false,
    --                 close_on_exit = true,
    --                 count = 10,
    --             })
    --             gemini_cli_term:toggle()
    --         end

    --         vim.keymap.set("n", "<Leader>g", function()
    --             toggle_gemini_cli_term()
    --         end, { noremap = true, silent = true })

    --         -- Key mappings for Claude Code or Cursor CLI
    --         local use_claude_code = os.getenv("USE_CLAUDE_CODE") or "0"
    --         local use_cursor_cli = os.getenv("USE_CURSOR_CLI") or "0"
    --         if use_claude_code == "1" then
    --             vim.api.nvim_set_keymap(
    --                 "n",
    --                 "<Leader>cs",
    --                 "<Cmd>ClaudeCodeAdd %<CR>",
    --                 { noremap = true, silent = true }
    --             )
    --             vim.api.nvim_set_keymap(
    --                 "v",
    --                 "<Leader>cs",
    --                 "<Cmd>ClaudeCodeSend<CR>",
    --                 { noremap = true, silent = true }
    --             )
    --         end

    --         -- NOTE: Use claudecode.nvim for Claude Code integration
    --         -- local function toggle_claude_code_term()
    --         --     local cursor_cli_term = Terminal:new({
    --         --         cmd = "claude",
    --         --         name = "Claude Code",
    --         --         dir = "git_dir",
    --         --         direction = "vertical",
    --         --         shade_terminals = false,
    --         --         close_on_exit = true,
    --         --         count = 11,
    --         --     })
    --         --     cursor_cli_term:toggle()
    --         -- end

    --         local function toggle_cursor_cli_term()
    --             local cursor_cli_term = Terminal:new({
    --                 cmd = "cursor-agent",
    --                 name = "Cursor CLI",
    --                 dir = "git_dir",
    --                 direction = "vertical",
    --                 shade_terminals = false,
    --                 close_on_exit = true,
    --                 count = 12,
    --             })
    --             cursor_cli_term:toggle()
    --         end

    --         local function toggle_c_term()
    --             if use_claude_code == "1" then
    --                 -- toggle_claude_code_term()
    --                 vim.cmd("ClaudeCode")
    --             elseif use_cursor_cli == "1" then
    --                 toggle_cursor_cli_term()
    --             else
    --                 print(
    --                     "Both USE_CLAUDE_CODE and USE_CURSOR_CLI are not set to 1. Please set one of them."
    --                 )
    --             end
    --         end

    --         vim.keymap.set("n", "<Leader>c", function()
    --             toggle_c_term()
    --         end, { noremap = true, silent = true })
    --     end,
    -- },
}
