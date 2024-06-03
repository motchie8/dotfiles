return {
	-- Render Markdown View
	{
		"MeanderingProgrammer/markdown.nvim",
		name = "render-markdown", -- Only needed if you have another plugin named markdown.nvim
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		ft = {
			"markdown",
			-- "vimwiki.markdown",
		},
		keys = {
			{ "<leader>rm", "<cmd>RenderMarkdownToggle<cr>", desc = "Toggle Render Markdown View" },
		},
		config = function()
			require("render-markdown").setup({
				file_types = { "markdown" },
			})
		end,
	},
}
