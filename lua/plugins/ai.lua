return {
	-- Interactive Chat with LLM models
	{
		"madox2/vim-ai",
		event = "VeryLazy",
		config = function()
			-- Custom roles file location
			vim.g.vim_ai_roles_config_file = "~/dotfiles/config/vim-ai-roles.ini"
			local default_model = os.getenv("VIM_AI_DEFAULT_MODEL") or "azure"
			local default_endpoint = os.getenv("VIM_AI_DEFAULT_ENDPOINT") or "http://0.0.0.0:4000/chat/completions"

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
					enable_auth = 0,
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
					vim.fn.system("litellm --config ~/dotfiles/config/lite-llm-config.yaml --port 4000 &")
					print("Started LiteLLM Proxy.")
				else
					print("LiteLLM Proxy is already running.")
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
		branch = "main",
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
		windows = {
			width = 40, -- default % based on available width
		},
		keys = {
			{
				"<shift><ctrl>i",
				"<cmd>AvanteChat<cr>",
				desc = "Start a chat session with AI",
			},
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
					auto_set_keymaps = true,
					auto_apply_diff_after_generation = true,
					jump_result_buffer_on_finish = true,
					enable_cursor_planning_mode = false,
				},
				mappings = {
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
					-- NOTE: The following will be safely set by avante.nvim
					ask = "<leader>aa",
					edit = "<leader>ae",
					refresh = "<leader>ar",
					focus = "<leader>af",
					toggle = {
						default = "<leader>at",
						debug = "<leader>ad",
						hint = "<leader>ah",
						suggestion = "<leader>as",
						repomap = "<leader>aR",
					},
					sidebar = {
						apply_all = "A",
						apply_cursor = "a",
						retry_user_request = "r",
						edit_user_request = "e",
						switch_windows = "<Tab>",
						reverse_switch_windows = "<S-Tab>",
						remove_file = "d",
						add_file = "@",
						close = { "<Esc>", "q" },
						---@alias AvanteCloseFromInput { normal: string | nil, insert: string | nil }
						---@type AvanteCloseFromInput | nil
						close_from_input = nil, -- e.g., { normal = "<Esc>", insert = "<C-d>" }
					},
					files = {
						add_current = "<leader>ac", -- Add current buffer to selected files
					},
					select_model = "<leader>a?", -- Select model command
				},
				azure = {
					endpoint = azure_endpoint,
					deployment = azure_deployment,
					api_version = "2024-06-01",
					timeout = 30000, -- Timeout in milliseconds
					temperature = 0,
					max_tokens = 4096,
				},
				claude = {
					endpoint = "https://api.anthropic.com",
					model = "claude-3-7-sonnet-20250219",
					timeout = 30000, -- Timeout in milliseconds
					temperature = 0,
					max_tokens = 8000,
				},
			})
		end,
	},
}
