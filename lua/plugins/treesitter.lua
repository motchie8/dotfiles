return {
	-- Treesitter
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		opts = {
			ensure_installed = {
				"all",
				"diff",
			},
			sync_install = false,
			auto_install = true,
			highlight = {
				enable = true,
			},
		},
	},
	-- Text objects
	{
		"RRethy/nvim-treesitter-textsubjects",
		config = function()
			require("nvim-treesitter.configs").setup({
				textsubjects = {
					enable = true,
					prev_selection = ",", -- (Optional) keymap to select the previous selection
					keymaps = {
						["."] = "textsubjects-smart",
						[";"] = "textsubjects-container-outer",
						["i;"] = {
							"textsubjects-container-inner",
							desc = "Select inside containers (classes, functions, etc.)",
						},
					},
				},
			})
		end,
	},
}
