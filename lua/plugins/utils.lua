return {
	-- Load .env file in Vim
	{
		"tpope/vim-dotenv",
		cmd = { "Dotenv" },
	},
	-- Cheetsheet
	{
		"sudormrfbin/cheatsheet.nvim",
		dependencies = {
			"nvim-telescope/telescope.nvim",
			"nvim-lua/popup.nvim",
			"nvim-lua/plenary.nvim",
		},
		keys = {
			{
				"<leader>s",
				"<cmd>Cheatsheet<cr>",
				desc = "Open Cheatsheet",
			},
		},
		config = function()
			vim.api.nvim_set_keymap("n", "<leader>s", "<Cmd>Cheatsheet<CR>", { noremap = true, silent = true })
			require("cheatsheet").setup({
				-- Whether to show bundled cheatsheets
				-- For generic cheatsheets like default, unicode, nerd-fonts, etc
				-- bundled_cheatsheets = {
				--     enabled = {},
				--     disabled = {},
				-- },
				bundled_cheatsheets = false,

				-- For plugin specific cheatsheets
				-- bundled_plugin_cheatsheets = {
				--     enabled = {},
				--     disabled = {},
				-- }
				bundled_plugin_cheatsheets = true,

				-- For bundled plugin cheatsheets, do not show a sheet if you
				-- don't have the plugin installed (searches runtimepath for
				-- same directory name)
				include_only_installed_plugins = true,

				-- Key mappings bound inside the telescope window
				telescope_mappings = {
					["<CR>"] = require("cheatsheet.telescope.actions").select_or_fill_commandline,
					["<C-CR>"] = require("cheatsheet.telescope.actions").select_or_execute,
					["<C-Y>"] = require("cheatsheet.telescope.actions").copy_cheat_value,
					["<C-E>"] = require("cheatsheet.telescope.actions").edit_user_cheatsheet,
				},
			})
		end,
	},
}
