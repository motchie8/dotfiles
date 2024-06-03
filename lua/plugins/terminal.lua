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
		end,
	},
}
