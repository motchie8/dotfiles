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
						"~/dotfiles/.venv/bin/litellm --config ~/dotfiles/config/lite-llm-config.yaml --port 4000 &"
					)
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
	-- Aider
	{
		"GeorgesAlkhouri/nvim-aider",
		cmd = "Aider",
		-- Example key mappings for common actions:
		keys = {
			{ "<leader>a", "<cmd>Aider toggle<cr>", desc = "Toggle Aider" },
			-- { "<leader>as", "<cmd>Aider send<cr>", desc = "Send to Aider", mode = { "n", "v" } },
			-- { "<leader>ac", "<cmd>Aider command<cr>", desc = "Aider Commands" },
			-- { "<leader>ab", "<cmd>Aider buffer<cr>", desc = "Send Buffer" },
			-- { "<leader>a+", "<cmd>Aider add<cr>", desc = "Add File" },
			-- { "<leader>a-", "<cmd>Aider drop<cr>", desc = "Drop File" },
			-- { "<leader>ar", "<cmd>Aider add readonly<cr>", desc = "Add Read-Only" },
			-- Example nvim-tree.lua integration if needed
			{ "<leader>a+", "<cmd>AiderTreeAddFile<cr>", desc = "Add File from Tree to Aider", ft = "NvimTree" },
			{ "<leader>a-", "<cmd>AiderTreeDropFile<cr>", desc = "Drop File from Tree from Aider", ft = "NvimTree" },
		},
		dependencies = {
			"folke/snacks.nvim",
			--- The below dependencies are optional
			"catppuccin/nvim",
			"nvim-tree/nvim-tree.lua",
			--- Neo-tree integration
			{
				"nvim-neo-tree/neo-tree.nvim",
				opts = function(_, opts)
					-- Example mapping configuration (already set by default)
					opts.window = {
						mappings = {
							["+"] = { "nvim_aider_add", desc = "add to aider" },
							["-"] = { "nvim_aider_drop", desc = "drop from aider" },
						},
					}
					require("nvim_aider.neo_tree").setup(opts)
				end,
			},
		},
		config = true,
		opts = {
			args = {
				"--no-auto-commits",
				"--pretty",
				"--stream",
				"--watch-files",
			},
		},
	},
}
