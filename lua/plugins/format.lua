return {
	{
		"sbdchd/neoformat",
		build = '[ ! -e "$HOME/.local/share/nvim/lazy/neoformat/autoload/neoformat/formatters/dbt.vim" ] && mkdir -p "$HOME/.local/share/nvim/lazy/neoformat/autoload/neoformat/formatters" && ln -s "$HOME/dotfiles/vim/autoload/neoformat/formatters/dbt.vim" "$HOME/.local/share/nvim/lazy/neoformat/autoload/neoformat/formatters/dbt.vim" || :',
		config = function()
			vim.api.nvim_create_user_command("EnableNeoFormat", function()
				local id = vim.api.nvim_create_augroup("neofmt", {})
				vim.api.nvim_create_autocmd({ "BufWritePre" }, {
					pattern = { "*" },
					command = "try | undojoin | Neoformat | catch /^Vim%((\a+))=:E790/ | finally | silent Neoformat | endtry",
					group = id,
				})
			end, {})
			vim.api.nvim_create_user_command("DisableNeoFormat", function()
				vim.api.nvim_del_augroup_by_name("neofmt")
			end, {})
			-- Enable Neoformat by default
			-- vim.api.nvim_command("EnableNeoFormat")
			-- for zsh
			vim.api.nvim_set_var("shfmt_opt", "-ci --indent 4")
			-- for markdown
			vim.api.nvim_set_keymap(
				"n",
				"<leader>fmd",
				"<Cmd>Neoformat! markdown<CR>",
				{ noremap = true, silent = true }
			)
			-- for sql
			vim.api.nvim_set_var("neoformat_enabled_sql", { "shandy_sqlfmt" })
		end,
	},
}
