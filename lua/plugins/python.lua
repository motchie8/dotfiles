return {
	-- Activate/Deactivate pyenv in Vim session
	{
		"lambdalisue/vim-pyenv",
		ft = { "python", "python3" },
	},
	-- Convert Jupyter Notebook file to python file by jupytext
	{
		"goerz/jupytext.vim",
		ft = { "ipynb" },
		config = function()
			vim.cmd([[
                execute 'source' '~/.local/share/nvim/lazy/jupytext.vim'
            ]])
			vim.api.nvim_set_var("jupytext_enable", 1)
			vim.api.nvim_set_var("jupytext_fmt", "py:percent")
			vim.api.nvim_set_var("jupytext_filetype_map", '{"py": "python"}')
			vim.api.nvim_set_var("jupytext_command", "~/.anyenv/envs/pyenv/versions/neovim3/bin/jupytext")
		end,
	},
}
