return {
	-- Toggle Terminal
	{
		"akinsho/toggleterm.nvim",
		event = "VeryLazy",
		version = "*",
		config = function()
			require("toggleterm").setup({
				size = 20,
				shade_terminals = false,
			})
			vim.api.nvim_set_keymap("n", "<Leader>t", "<Cmd>ToggleTerm<CR>", { noremap = true, silent = true })
			vim.api.nvim_set_keymap("n", "<Leader>tt", "<Cmd>2ToggleTerm<CR>", { noremap = true, silent = true })
			vim.api.nvim_set_keymap(
				"n",
				-- float
				"<Leader>tf",
				"<Cmd>ToggleTerm direction=float<CR>",
				{ noremap = true, silent = true }
			)
			vim.api.nvim_set_keymap(
				"n",
				-- horizontal
				"<Leader>th",
				"<Cmd>ToggleTerm direction=horizontal<CR>",
				{ noremap = true, silent = true }
			)
			vim.api.nvim_set_keymap(
				"n",
				-- vertical
				"<Leader>tv",
				"<Cmd>ToggleTerm direction=vertical size=70<CR>",
				{ noremap = true, silent = true }
			)
			-- vim.api.nvim_set_keymap(
			-- 	"n",
			-- 	-- tab
			-- 	"<Leader>ct",
			-- 	"<Cmd>ToggleTerm direction=tab<CR>",
			-- 	{ noremap = true, silent = true }
			-- )
			local Terminal = require("toggleterm.terminal").Terminal
			function toggle_gemini_cli_term(opts)
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

			vim.api.nvim_set_keymap(
				"n",
				"<Leader>g",
				"<Cmd>lua toggle_gemini_cli_term()<CR>",
				{ noremap = true, silent = true }
			)

			function toggle_claude_code_term(opts)
				local claude_code_term = Terminal:new({
					cmd = "claude",
					name = "Claude Code",
					dir = "git_dir",
					direction = "vertical",
					shade_terminals = false,
					close_on_exit = true,
					count = 11,
				})
				claude_code_term:toggle()
			end

			function toggle_cursor_cli_term(opts)
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

			local use_claude_code = os.getenv("USE_CLAUDE_CODE") or "0"
			local use_cursor_cli = os.getenv("USE_CURSOR_CLI") or "0"

			function toggle_c_term(opts)
				if use_claude_code == "1" then
					toggle_claude_code_term(opts)
				elseif use_cursor_cli == "1" then
					toggle_cursor_cli_term(opts)
				else
					print("Both USE_CLAUDE_CODE and USE_CURSOR_CLI are not set to 1. Please set one of them.")
				end
			end

			vim.api.nvim_set_keymap("n", "<Leader>c", "<Cmd>lua toggle_c_term()<CR>", { noremap = true, silent = true })
		end,
	},
}
