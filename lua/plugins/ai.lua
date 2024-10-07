return {
	-- Interactive Chat with GPT models
	{
		"madox2/vim-ai",
		event = "VeryLazy",
		config = function()
			-- load default configs from environment variables
			local model = os.getenv("OPENAI_API_MODEL")
			local endpoint_url = os.getenv("OPENAI_API_ENDPOINT_URL")
			local default_role = os.getenv("VIM_AI_DEFAULT_ROLE")

			local initial_chat_prompt = [[
            >>> system
            
            You are a general assistant.
            If you attach a code block add syntax type after ``` to enable syntax highlighting.
            ]]

			vim.g.vim_ai_chat = {
				options = {
					model = model,
					endpoint_url = endpoint_url,
					max_tokens = 1000,
					temperature = 1,
					request_timeout = 20,
					selection_boundary = "",
					initial_prompt = initial_chat_prompt,
				},
				ui = {
					code_syntax_enabled = 1,
					populate_options = 0,
					open_chat_command = "preset_below",
					scratch_buffer_keep_open = 0,
					paste_mode = 1,
				},
			}
			-- specify role config
			vim.g.vim_ai_roles_config_file = "~/dotfiles/config/vim-ai-roles.ini"

			-- Check if litellm is running
			local function is_litellm_running()
				local handle = io.popen("pgrep litellm")
				-- if handle is nil, then litellm is not running
				local result = handle:read("*a")
				handle:close()
				return result ~= ""
			end

			vim.api.nvim_create_user_command("AIProxyStart", function()
				if not is_litellm_running() then
					vim.fn.system("litellm --config ~/dotfiles/config/lite-llm-config.yaml &")
					print("Started LiteLLM Proxy.")
				else
					print("LiteLLM Proxy is already running.")
				end
			end, {})

			local function start_new_conversation_with_saving_chat()
				local chat_file_path = "~/vimwiki/aichat/"
				local unique_id = vim.fn.system("uuidgen")
				local timestamp = os.date("%Y-%m-%d_%H%M%S")
				local aichat_filename = timestamp .. "_" .. string.sub(unique_id, 1, 8) .. ".aichat"
				vim.cmd("AINewChat")
				vim.bo.buftype = ""
				vim.cmd("saveas " .. chat_file_path .. aichat_filename)
			end

			vim.api.nvim_create_user_command("AISavingChat", function()
				start_new_conversation_with_saving_chat()
			end, {})

			vim.api.nvim_create_user_command("AIIncludingChat", function()
				local bufnr = vim.api.nvim_get_current_buf()
				local current_filename = vim.api.nvim_buf_get_name(bufnr)
				start_new_conversation_with_saving_chat()
				vim.api.nvim_buf_set_lines(0, 0, 0, false, {
					">>> include",
					"",
					current_filename,
					"",
				})
			end, {})

			vim.api.nvim_create_user_command("AITranslationChat", function()
				start_new_conversation_with_saving_chat()
				vim.api.nvim_buf_set_lines(0, 0, 0, false, {
					">>> system",
					"",
					"Please write the following content in natural English.",
					"",
				})
			end, {})

			vim.api.nvim_create_user_command("AIFileTranslation", function()
				local bufnr = vim.api.nvim_get_current_buf()
				local current_filename = vim.api.nvim_buf_get_name(bufnr)
				start_new_conversation_with_saving_chat()
				-- Delete all lines in the buffer
				local current_buf = vim.api.nvim_get_current_buf()
				local line_count = vim.api.nvim_buf_line_count(current_buf)
				vim.api.nvim_buf_set_lines(current_buf, 0, line_count, false, {})
				-- Add lines to the top of buffer
				vim.api.nvim_buf_set_lines(0, 0, 0, false, {
					">>> user",
					"",
					"Please write the content of the following file in natural English.",
					"",
					">>> include",
					"",
					current_filename,
					"",
				})
			end, {})
			vim.api.nvim_set_keymap("n", "Te", "<Cmd>AIEdit translate into english<CR>", { noremap = true })
			vim.api.nvim_set_keymap("x", "Te", "<Cmd>AIEdit translate into english<CR>", { noremap = true })
			vim.api.nvim_create_user_command("AIC", function()
				if default_role == nil or default_role == "" then
					vim.cmd("AIChat")
				else
					vim.cmd("AIChat /" .. default_role)
				end
			end, {})
		end,
	},
	-- Copilot
	{
		"github/copilot.vim",
		config = function()
			vim.g.copilot_filetypes = {
				yaml = true,
				markdown = true,
				gitcommit = true,
				gitrebase = true,
			}
		end,
	},
	-- Copilot chat
	{
		"CopilotC-Nvim/CopilotChat.nvim",
		branch = "canary",
		event = "VeryLazy",
		dependencies = {
			{ "github/copilot.vim" },
			{ "nvim-lua/plenary.nvim" },
		},
		config = function()
			require("CopilotChat").setup({})
			vim.api.nvim_create_user_command("CopilotChatQuick", function()
				local input = vim.fn.input("Quick Chat: ")
				if input ~= "" then
					require("CopilotChat").ask(input, { selection = require("CopilotChat.select").buffer })
				end
			end, {})
		end,
	},
	-- Emulate the behaviour of the Cursor AI IDE
	{
		"yetone/avante.nvim",
		event = "VeryLazy",
		lazy = false,
		version = false, -- set this if you want to always pull the latest change
		opts = {
			-- add any opts here
		},
		-- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
		build = "make",
		-- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"stevearc/dressing.nvim",
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
			--- The below dependencies are optional,
			"nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
			-- "zbirenbaum/copilot.lua", -- for providers='copilot'
			{
				-- support for image pasting
				-- "HakonHarnes/img-clip.nvim",
				-- event = "VeryLazy",
				-- opts = {
				-- 	-- recommended settings
				-- 	default = {
				-- 		embed_image_as_base64 = false,
				-- 		prompt_for_file_name = false,
				-- 		drag_and_drop = {
				-- 			insert_mode = true,
				-- 		},
				-- 		-- required for Windows users
				-- 		use_absolute_path = true,
				-- 	},
				-- },
			},
			{
				-- Make sure to set this up properly if you have lazy=true
				"MeanderingProgrammer/render-markdown.nvim",
				opts = {
					file_types = { "markdown", "Avante" },
				},
				ft = { "markdown", "Avante" },
			},
		},
		mappings = {
			--- @class AvanteConflictMappings
			diff = {
				ours = "co",
				theirs = "ct",
				all_theirs = "ca",
				both = "cb",
				cursor = "cc",
				next = "]x",
				prev = "[x",
			},
			suggestion = {
				accept = "<M-l>",
				next = "<M-]>",
				prev = "<M-[>",
				dismiss = "<C-]>",
			},
			jump = {
				next = "]]",
				prev = "[[",
			},
			submit = {
				normal = "<CR>",
				insert = "<C-s>",
			},
			sidebar = {
				switch_windows = "<Tab>",
				reverse_switch_windows = "<S-Tab>",
			},
		},
		windows = {
			width = 40, -- default % based on available width
		},
		config = function()
			local provider = os.getenv("AVANTE_PROVIDER")
			local auto_suggestions_provider = os.getenv("AVANTE_AUTO_SUGGESTIONS_PROVIDER") or "copilot"
			local azure_endpoint = os.getenv("AZURE_ENDPOINT")
			local azure_deployment = os.getenv("AZURE_DEPLOYMENT_NAME")
			require("avante").setup({
				provider = provider,
				auto_suggestions_provider = auto_suggestions_provider,
				behaviour = {
					auto_suggestions = false, -- Experimental stage and may need much cost
				},
				azure = {
					endpoint = azure_endpoint,
					deployment = azure_deployment,
					api_version = "2024-06-01",
					timeout = 30000, -- Timeout in milliseconds
					temperature = 0,
					max_tokens = 4096,
					["local"] = false,
				},
			})
		end,
	},
}
