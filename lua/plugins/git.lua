return {
	-- Git commands and Gdiffsplit
	{
		"tpope/vim-fugitive",
		event = "VeryLazy",
	},
	-- Git decoration
	{
		"lewis6991/gitsigns.nvim",
		config = function()
			require("gitsigns").setup()
		end,
	},
	-- Git diffview
	{
		"sindrets/diffview.nvim",
		cmd = "DiffviewOpen",
		dependencies = { "nvim-lua/plenary.nvim" },
	},
}
