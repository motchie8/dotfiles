return {
	-- increment/decrement
	{
		"monaqa/dial.nvim",
		keys = {
			{
				"<C-a>",
				function()
					require("dial.map").manipulate("increment", "normal")
				end,
				desc = "Increment in Normal mode",
			},
			{
				"<C-x>",
				function()
					require("dial.map").manipulate("decrement", "normal")
				end,
				desc = "Decrement in Normal mode",
			},
			{
				"<C-a>",
				function()
					require("dial.map").manipulate("increment", "visual")
				end,
				mode = "v",
				desc = "Increment Dial in Visual mode",
			},
			{
				"<C-x>",
				function()
					require("dial.map").manipulate("decrement", "visual")
				end,
				mode = "v",
				desc = "Decrement Dial in Visual mode",
			},
		},
	},
	-- comment out
	{
		"numToStr/Comment.nvim",
		keys = {
			{
				"gc",
				desc = "Toggles the region using linewise comment in normal mode",
			},
			{
				"gb",
				desc = "Toggles the region using blockwise comment in normal mode",
			},
			{
				"gc",
				mode = "v",
				desc = "Toggles the region using linewise comment in visual mode",
			},
			{
				"gb",
				mode = "v",
				desc = "Toggles the region using blockwise comment in visual mode",
			},
		},
	},
	-- Autocomplete brackets
	{
		"jiangmiao/auto-pairs",
		config = function()
			vim.g.AutoPairsMapSpace = 0
		end,
	},
}
