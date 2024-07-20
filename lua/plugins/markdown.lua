return {
	-- Render Markdown View
	{
		"MeanderingProgrammer/markdown.nvim",
		-- NOTE: Currently disabled due to incompatibility with vimwiki.markdown
		enabled = false,
		name = "render-markdown", -- Only needed if you have another plugin named markdown.nvim
		dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
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
