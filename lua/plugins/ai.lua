return {
    -- Interactive Chat with LLM models
    {
        "madox2/vim-ai",
        event = "VeryLazy",
        config = function()
            -- Custom roles file location
            vim.g.vim_ai_roles_config_file = "~/dotfiles/config/vim-ai/vim-ai-roles.ini"
            local default_model = os.getenv("VIM_AI_DEFAULT_MODEL") or "azure"
            local default_endpoint = os.getenv("VIM_AI_DEFAULT_ENDPOINT")
                or "http://0.0.0.0:4000/chat/completions"

            local default_complete_prompt =
                "You are an agent with knowledge of software engineering. Generate consise commands to realize the content asked. Do not provide any explanation or comments. If you answer in a code, do not wrap it in code block."
            vim.g.vim_ai_complete = {
                prompt = "",
                engine = "chat",
                options = {
                    model = default_model,
                    endpoint_url = default_endpoint,
                    max_tokens = 0,
                    max_completion_tokens = 0,
                    temperature = 1.0,
                    request_timeout = 20,
                    stream = 1,
                    auth_type = "none",
                    token_file_path = "",
                    selection_boundary = "#####",
                    initial_prompt = default_complete_prompt,
                },
                ui = {
                    paste_mode = 1,
                },
            }

            -- Open new chat with conversation saving
            vim.api.nvim_create_user_command("AISavingChat", function(opts)
                local chat_file_path = "~/vimwiki/aichat/"
                local unique_id = vim.fn.system("uuidgen")
                local timestamp = os.date("%Y-%m-%d_%H%M%S")
                local aichat_filename = timestamp .. "_" .. string.sub(unique_id, 1, 8) .. ".aichat"
                local default_role = "/below"
                local args = opts.args
                if args ~= nil and args ~= "" then
                    local predefined_role = args[1]
                    vim.cmd("AIChat " .. predefined_role)
                else
                    vim.cmd("AIChat" .. default_role)
                end
                vim.bo.buftype = ""
                vim.cmd("saveas " .. chat_file_path .. aichat_filename)
            end, { nargs = "?" })

            -- Continue chat. If default role is set, use it.
            vim.api.nvim_create_user_command("AIC", function(opts)
                local default_role = os.getenv("VIM_AI_DEFAULT_ROLE")
                local args = opts.args
                if args ~= nil and args ~= "" then
                    vim.cmd("AIChat " .. args[1])
                elseif default_role ~= nil and default_role ~= "" then
                    vim.cmd("AIChat /" .. default_role)
                else
                    vim.cmd("AIChat")
                end
            end, { nargs = "?" })

            -- Open new chat including the current buffer
            vim.api.nvim_create_user_command("AIIncludingChat", function()
                local bufnr = vim.api.nvim_get_current_buf()
                local current_filename = vim.api.nvim_buf_get_name(bufnr)
                vim.cmd("AISavingChat")
                vim.api.nvim_buf_set_lines(0, 0, 0, false, {
                    ">>> include",
                    "",
                    current_filename,
                    "",
                })
            end, {})

            -- Open new chat with the prompt for translation
            vim.api.nvim_create_user_command("AITranslationChat", function()
                vim.cmd("AISavingChat")
                vim.api.nvim_buf_set_lines(0, 0, 0, false, {
                    ">>> system",
                    "",
                    "Please write the following content in natural English.",
                    "",
                })
            end, {})

            -- Check if litellm is running
            local function is_litellm_running()
                local handle = io.popen("ps aux | grep '[l]itellm'")
                -- if handle is nil, then litellm is not running
                -- check if the result is not empty
                if handle == nil then
                    return false
                end
                local result = handle:read("*a")
                handle:close()
                return result ~= ""
            end

            -- Start litellm proxy if not running
            vim.api.nvim_create_user_command("AIProxyStart", function()
                if not is_litellm_running() then
                    vim.fn.system(
                        "~/dotfiles/.venv/bin/litellm --config ~/dotfiles/config/litellm/lite-llm-config.yaml --port 4000 &"
                    )
                    print("Started LiteLLM Proxy.")
                else
                    print("LiteLLM Proxy is already running.")
                end
            end, {})
        end,
    },
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
        },
    },
    -- For Claude Code, Cursor CLI and Gemini CLI by sidedeck.nvim
    {
        "folke/sidekick.nvim",
        opts = {
            -- add any options here
        },
        keys = {
            {
                "<tab>",
                function()
                    -- if there is a next edit, jump to it, otherwise apply it if any
                    if not require("sidekick").nes_jump_or_apply() then
                        return "<Tab>" -- fallback to normal tab
                    end
                end,
                expr = true,
                desc = "Goto/Apply Next Edit Suggestion",
            },
            {
                "<leader>aa",
                function()
                    require("sidekick.cli").toggle()
                end,
                desc = "Sidekick Toggle CLI",
                mode = { "n", "t", "i", "x" },
            },
            {
                "<leader>as",
                function()
                    require("sidekick.cli").select()
                end,
                -- Or to select only installed tools:
                -- require("sidekick.cli").select({ filter = { installed = true } })
                desc = "Select CLI",
            },
            {
                "<leader>ad",
                function()
                    require("sidekick.cli").close()
                end,
                desc = "Detach a CLI Session",
            },
            {
                "<leader>at",
                function()
                    require("sidekick.cli").send({ msg = "{this}" })
                end,
                mode = { "x", "n" },
                desc = "Send This",
            },
            {
                "<leader>af",
                function()
                    require("sidekick.cli").send({ msg = "{file}" })
                end,
                desc = "Send File",
            },
            {
                "<leader>av",
                function()
                    require("sidekick.cli").send({ msg = "{selection}" })
                end,
                mode = { "x" },
                desc = "Send Visual Selection",
            },
            {
                "<leader>ap",
                function()
                    require("sidekick.cli").prompt()
                end,
                mode = { "n", "x" },
                desc = "Sidekick Select Prompt",
            },
            -- Example of a keybinding to open Claude directly
            {
                "<leader>ac",
                function()
                    local use_claude_code = os.getenv("USE_CLAUDE_CODE") or "0"
                    local use_cursor_cli = os.getenv("USE_CURSOR_CLI") or "0"
                    if use_claude_code == "1" then
                        require("sidekick.cli").toggle({ name = "claude", focus = true })
                    elseif use_cursor_cli == "1" then
                        require("sidekick.cli").toggle({ name = "cursor", focus = true })
                    else
                        print(
                            "Both USE_CLAUDE_CODE and USE_CURSOR_CLI are not set to 1. Please set one of them."
                        )
                    end
                end,
                desc = "Sidekick Toggle Claude/Cursor CLI",
            },
        },
    },
    -- For Claude Code, Cursor CLI and Gemini CLI by toggleterm.nvim
    {
        "coder/claudecode.nvim",
        dependencies = { "folke/snacks.nvim", "akinsho/toggleterm.nvim" },
        keys = {
            { "<leader>c", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
        },
        config = function()
            require("claudecode").setup({})
            -- Key mappings for Gemini CLI
            local Terminal = require("toggleterm.terminal").Terminal
            local function toggle_gemini_cli_term()
                local gemini_cli_term = Terminal:new({
                    cmd = "gemini",
                    name = "Gemini CLI",
                    dir = "git_dir",
                    direction = "vertical",
                    shade_terminals = false,
                    close_on_exit = true,
                    count = 10,
                })
                gemini_cli_term:toggle()
            end

            vim.keymap.set("n", "<Leader>g", function()
                toggle_gemini_cli_term()
            end, { noremap = true, silent = true })

            -- Key mappings for Claude Code or Cursor CLI
            local use_claude_code = os.getenv("USE_CLAUDE_CODE") or "0"
            local use_cursor_cli = os.getenv("USE_CURSOR_CLI") or "0"
            if use_claude_code == "1" then
                vim.api.nvim_set_keymap(
                    "n",
                    "<Leader>cs",
                    "<Cmd>ClaudeCodeAdd %<CR>",
                    { noremap = true, silent = true }
                )
                vim.api.nvim_set_keymap(
                    "v",
                    "<Leader>cs",
                    "<Cmd>ClaudeCodeSend<CR>",
                    { noremap = true, silent = true }
                )
            end

            -- NOTE: Use claudecode.nvim for Claude Code integration
            -- local function toggle_claude_code_term()
            --     local cursor_cli_term = Terminal:new({
            --         cmd = "claude",
            --         name = "Claude Code",
            --         dir = "git_dir",
            --         direction = "vertical",
            --         shade_terminals = false,
            --         close_on_exit = true,
            --         count = 11,
            --     })
            --     cursor_cli_term:toggle()
            -- end

            local function toggle_cursor_cli_term()
                local cursor_cli_term = Terminal:new({
                    cmd = "cursor-agent",
                    name = "Cursor CLI",
                    dir = "git_dir",
                    direction = "vertical",
                    shade_terminals = false,
                    close_on_exit = true,
                    count = 12,
                })
                cursor_cli_term:toggle()
            end

            local function toggle_c_term()
                if use_claude_code == "1" then
                    -- toggle_claude_code_term()
                    vim.cmd("ClaudeCode")
                elseif use_cursor_cli == "1" then
                    toggle_cursor_cli_term()
                else
                    print(
                        "Both USE_CLAUDE_CODE and USE_CURSOR_CLI are not set to 1. Please set one of them."
                    )
                end
            end

            vim.keymap.set("n", "<Leader>c", function()
                toggle_c_term()
            end, { noremap = true, silent = true })
        end,
    },
}
