return {
	-- Toggle Terminal
	{
		"akinsho/toggleterm.nvim",
		event = "VeryLazy",
		version = "*",
		config = function()
			require("toggleterm").setup({
				size = 16,
				shade_terminals = false,
			})
			vim.api.nvim_set_keymap("n", "<Leader>c", "<Cmd>ToggleTerm<CR>", { noremap = true, silent = true })
			vim.api.nvim_set_keymap(
				"n",
				-- float
				"<Leader>cf",
				"<Cmd>ToggleTerm direction=float<CR>",
				{ noremap = true, silent = true }
			)
			vim.api.nvim_set_keymap(
				"n",
				-- below
				"<Leader>cb",
				"<Cmd>ToggleTerm direction=horizontal<CR>",
				{ noremap = true, silent = true }
			)
			vim.api.nvim_set_keymap(
				"n",
				-- horizontal
				"<Leader>ch",
				"<Cmd>ToggleTerm direction=horizontal<CR>",
				{ noremap = true, silent = true }
			)
			vim.api.nvim_set_keymap(
				"n",
				-- tab
				"<Leader>ct",
				"<Cmd>ToggleTerm direction=tab<CR>",
				{ noremap = true, silent = true }
			)
		end,
	},
}
