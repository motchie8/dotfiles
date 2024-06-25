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
	-- Intelligent prioritization for telescope
	{
		"nvim-telescope/telescope-frecency.nvim",
		dependencies = {
			"nvim-telescope/telescope.nvim",
			"nvim-tree/nvim-web-devicons",
		},
		event = "VeryLazy",
		config = function()
			require("telescope").load_extension("frecency")
			vim.api.nvim_set_keymap("n", "sp", "<cmd>Telescope frecency<cr>", { noremap = true })
		end,
		-- keys = {
		-- 	{
		-- 		"sp",
		-- 		function()
		-- 			require("telescope").extensions.frecency.frecency()
		-- 		end,
		-- 		desc = "Intelligent prioritization",
		-- 	},
		-- },
	},
	-- Change picker by command prefix
	{
		"d00h/telescope-any",
		dependencies = { "nvim-telescope/telescope.nvim" },
		keys = {
			{
				"ta",
				"<cmd>TelescopeAny<cr>",
				desc = "Switch telescope picker by prefix",
			},
		},
		config = function()
			local builtin = require("telescope.builtin")
			local opts = {
				pickers = {
					-- File Pickers
					[""] = builtin.find_files,
					["/"] = builtin.live_grep,
					["gf "] = builtin.git_files,
					[":"] = builtin.current_buffer_fuzzy_find,

					-- Vim Pickers
					["b "] = builtin.buffers,
					["o "] = builtin.oldfiles,
					["q "] = builtin.quickfix,
					["command "] = builtin.commands,
					["history "] = builtin.command_history,
					["man "] = builtin.man_pages,
					["options "] = builtin.vim_options,
					["keymaps "] = builtin.keymaps,

					-- Neovim LSP Pickers
					["d "] = builtin.diagnostics,

					-- Git Pickers
					["gc "] = builtin.git_commits,
					["gbc "] = builtin.git_bcommits,
					["gb "] = builtin.git_branches,
					["gs "] = builtin.git_status,

					-- Treesitter Picker
					["tree "] = builtin.treesitter,
				},
			}
			local telescope_any = require("telescope-any").create_telescope_any(opts)
			vim.api.nvim_create_user_command("TelescopeAny", telescope_any, { nargs = 0 })
			vim.api.nvim_set_keymap("n", "ta", "<Cmd>TelescopeAny<CR>", {
				noremap = true,
				silent = true,
			})
		end,
	},
}
