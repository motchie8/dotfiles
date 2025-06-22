return {
	-- Telescope
	{
		"nvim-telescope/telescope.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		event = "VeryLazy",
		config = function()
			vim.api.nvim_set_keymap("n", "sb", "<Cmd>Telescope buffers<CR>", { noremap = true })
			vim.api.nvim_set_keymap("n", "sq", "<Cmd>Telescope quickfix<CR>", { noremap = true })
			vim.api.nvim_set_keymap("n", "sf", "<Cmd>Telescope find_files<CR>", { noremap = true })
			vim.api.nvim_set_keymap("n", "sg", "<Cmd>Telescope git_files<CR>", { noremap = true })
			vim.api.nvim_set_keymap("n", "sc", "<Cmd>Telescope live_grep<CR>", { noremap = true })
			vim.api.nvim_set_keymap("n", "so", "<Cmd>Telescope oldfiles<CR>", { noremap = true })
			vim.api.nvim_set_keymap("n", "s/", "<Cmd>Telescope current_buffer_fuzzy_find<CR>", { noremap = true })
			vim.api.nvim_set_keymap("n", "ss", "<Cmd>Telescope current_buffer_fuzzy_find<CR>", { noremap = true })
			-- list vim-ai chat log files
			vim.api.nvim_set_keymap(
				"n",
				"sa",
				"<Cmd>Telescope live_grep cwd=$HOME/vimwiki/aichat<CR>",
				{ noremap = true, silent = true }
			)
		end,
	},
	-- Calculating matching score for telescope
	{
		"nvim-telescope/telescope-fzf-native.nvim",
		dependencies = { "nvim-telescope/telescope.nvim" },
		event = "VeryLazy",
		build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build",
		config = function()
			require("telescope").setup({})
			require("telescope").load_extension("fzf")
		end,
	},
	-- quickfix + telescope
	{
		"atusy/qfscope.nvim",
		dependencies = { "nvim-telescope/telescope.nvim" },
		event = "VeryLazy",
		config = function()
			local qfs_actions = require("qfscope.actions")
			require("telescope").setup({
				defaults = {
					mappings = {
						i = {
							["<C-G><C-G>"] = qfs_actions.qfscope_search_filename,
							["<C-G><C-F>"] = qfs_actions.qfscope_grep_filename,
							["<C-G><C-L>"] = qfs_actions.qfscope_grep_line,
							["<C-G><C-T>"] = qfs_actions.qfscope_grep_text,
						},
					},
				},
			})
		end,
	},
}
