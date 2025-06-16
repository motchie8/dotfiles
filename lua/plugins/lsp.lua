return {
	-- Previw code with code actions applied
	{
		"aznhe21/actions-preview.nvim",
		event = "VeryLazy",
		opts = {
			telescope = {
				sorting_strategy = "ascending",
				layout_strategy = "vertical",
				layout_config = {
					width = 0.8,
					height = 0.9,
					prompt_position = "top",
					preview_cutoff = 20,
					preview_height = function(_, _, max_lines)
						return max_lines - 15
					end,
				},
			},
		},
		config = function()
			vim.keymap.set("n", "<leader>ca", require("actions-preview").code_actions)
		end,
	},
	{
		"mason-org/mason.nvim",
		opts = {
			ui = {
				icons = {
					package_installed = "✓",
					package_pending = "➜",
					package_uninstalled = "✗",
				},
			},
		},
	},
	{
		"mason-org/mason-lspconfig.nvim",
		dependencies = {
			"mason-org/mason.nvim",
			"neovim/nvim-lspconfig",
		},
		opts = {
			automatic_enable = true,
			ensure_installed = {
				-- [LSP] Lua
				"lua_ls", -- "lua-language-server",
				-- [LSP] Python
				"pyright",
				-- [Linter] [Formatter] [LSP] Python
				"ruff",
				-- [LSP] [Formatter] [Linter] JSON, Javascript, Typescript, JSX, CSS, GraphQL
				"biome",
				-- [Formatter] Markdown, YAML, JSON, CSS, HTML, JSX, Javascript, Typescript
				-- "prettier",
				-- [Linter] Markdown, Text
				-- for formatting: setup none-ls.nvim: https://github.com/nvimtools/none-ls.nvim/blob/main/doc/BUILTINS.md#textlint-2
				-- "textlint",
				-- [Formatter] dbt, SQL
				"sqlfmt",
				-- [Linter] dbt, SQL
				-- for formatting: setup none-ls.nvim: https://github.com/nvimtools/none-ls.nvim/blob/main/doc/BUILTINS.md#textlint-2
				"sqlfluff",
				-- [LSP] [Formatter] toml
				"taplo",
				-- [Formatter] [Linter] [Runtime] terraform
				"terraform",
				-- [LSP] terraform
				"terraform-ls",
				-- [LSP] bash, zsh
				"bash-language-server",
				-- [Linter] bash
				"shellcheck",
				-- [LSP] Docker
				"docker-compose-language-service",
			},
		},
	},
	{
		"neovim/nvim-lspconfig",
		dependencies = { "saghen/blink.cmp" },
		opts = {
			servers = {},
		},
		config = function(_, opts)
			local lspconfig = require("lspconfig")
			for server, config in pairs(opts.servers) do
				-- passing config.capabilities to blink.cmp merges with the capabilities in your
				-- `opts[server].capabilities, if you've defined it
				config.capabilities = require("blink.cmp").get_lsp_capabilities(config.capabilities)
				lspconfig[server].setup(config)
			end
		end,
	},
	{
		"saghen/blink.cmp",
		event = { "InsertEnter", "CmdlineEnter" },
		-- optional: provides snippets for the snippet source
		dependencies = {
			"rafamadriz/friendly-snippets",
			"L3MON4D3/LuaSnip",
		},

		-- use a release tag to download pre-built binaries
		version = "1.*",
		-- AND/OR build from source, requires nightly: https://rust-lang.github.io/rustup/concepts/channels.html#working-with-nightly-rust
		-- build = 'cargo build --release',
		-- If you use nix, you can build from source using latest nightly rust with:
		-- build = 'nix run .#build-plugin',

		---@module 'blink.cmp'
		---@type blink.cmp.Config
		opts = {
			-- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
			-- 'super-tab' for mappings similar to vscode (tab to accept)
			-- 'enter' for enter to accept
			-- 'none' for no mappings
			--
			-- All presets have the following mappings:
			-- C-space: Open menu or open docs if already open
			-- C-n/C-p or Up/Down: Select next/previous item
			-- C-e: Hide menu
			-- C-k: Toggle signature help (if signature.enabled = true)
			--
			-- See :h blink-cmp-config-keymap for defining your own keymap
			keymap = {
				preset = "none",
				["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
				-- ["<C-e>"] = { "hide", "fallback" },
				["<CR>"] = { "accept", "fallback" },
				-- ["<Tab>"] = { "snippet_forward", "fallback" },
				-- ["<S-Tab>"] = { "snippet_backward", "fallback" },

				["<Up>"] = { "select_prev", "fallback" },
				["<Down>"] = { "select_next", "fallback" },
				-- ["<C-p>"] = { "select_prev", "fallback_to_mappings" },
				-- ["<C-n>"] = { "select_next", "fallback_to_mappings" },

				["<C-b>"] = { "scroll_documentation_up", "fallback" },
				["<C-f>"] = { "scroll_documentation_down", "fallback" },

				["<C-k>"] = { "show_signature", "hide_signature", "fallback" },
			},

			snippets = { preset = "luasnip" },

			appearance = {
				-- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
				-- Adjusts spacing to ensure icons are aligned
				nerd_font_variant = "mono",
			},

			-- (Default) Only show the documentation popup when manually triggered
			completion = { documentation = { auto_show = true, auto_show_delay_ms = 500 } },

			-- Default list of enabled providers defined so that you can extend it
			-- elsewhere in your config, without redefining it, due to `opts_extend`
			sources = {
				default = { "snippets", "lsp", "path", "buffer" },
			},

			-- (Default) Rust fuzzy matcher for typo resistance and significantly better performance
			-- You may use a lua implementation instead by using `implementation = "lua"` or fallback to the lua implementation,
			-- when the Rust fuzzy matcher is not available, by using `implementation = "prefer_rust"`
			--
			-- See the fuzzy documentation for more information
			fuzzy = { implementation = "prefer_rust_with_warning" },
		},
		opts_extend = { "sources.default" },
	},
	{
		"nvimtools/none-ls.nvim",
		enabled = false,
		event = "VeryLazy",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			local none_ls = require("none-ls")
			none_ls.setup({
				sources = {},
			})
		end,
	},
	{
		"L3MON4D3/LuaSnip",
		-- follow latest release.
		version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
		-- install jsregexp (optional!).
		build = "make install_jsregexp",
		config = function() end,
	},
	{
		"ray-x/lsp_signature.nvim",
		enabled = false,
		event = "VeryLazy",
		config = function()
			require("lsp_signature").setup({})
		end,
	},
	{
		"j-hui/fidget.nvim",
		enabled = false,
		event = "VeryLazy",
		tag = "legacy",
		config = function()
			require("fidget").setup({})
		end,
	},
	{
		"onsails/lspkind.nvim",
		enabled = false,
		event = "VeryLazy",
	},
	{
		"folke/trouble.nvim",
		enabled = false,
		event = "VeryLazy",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		cmd = { "TroubleToggle", "Trouble" },
		config = function()
			require("trouble").setup({})
		end,
	},
	{
		"neoclide/coc.nvim",
		enabled = false,
		branch = "release",
		config = function()
			-- https://raw.githubusercontent.com/neoclide/coc.nvim/master/doc/coc-example-config.lua
			-- Some servers have issues with backup files, see #649
			vim.opt.backup = false
			vim.opt.writebackup = false

			-- Having longer updatetime (default is 4000 ms = 4s) leads to noticeable
			-- delays and poor user experience
			vim.opt.updatetime = 50

			-- Always show the signcolumn, otherwise it would shift the text each time
			-- diagnostics appeared/became resolved
			vim.opt.signcolumn = "yes"

			local keyset = vim.keymap.set
			-- Autocomplete
			function _G.check_back_space()
				local col = vim.fn.col(".") - 1
				return col == 0 or vim.fn.getline("."):sub(col, col):match("%s") ~= nil
			end

			-- Use Tab for trigger completion with characters ahead and navigate
			-- NOTE: There's always a completion item selected by default, you may want to enable
			-- no select by setting `"suggest.noselect": true` in your configuration file
			-- NOTE: Use command ':verbose imap <tab>' to make sure Tab is not mapped by
			-- other plugins before putting this into your config
			local opts = { silent = true, noremap = true, expr = true, replace_keycodes = false }
			-- HACK: Disable Tab Key for Copilot
			-- keyset("i", "<TAB>", 'coc#pum#visible() ? coc#pum#next(1) : v:lua.check_back_space() ? "<TAB>" : coc#refresh()', opts)
			-- keyset("i", "<S-TAB>", [[coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"]], opts)

			-- Make <CR> to accept selected completion item or notify coc.nvim to format
			-- <C-g>u breaks current undo, please make your own choice
			keyset(
				"i",
				"<cr>",
				[[coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"]],
				opts
			)

			-- Use <c-j> to trigger snippets
			keyset("i", "<c-j>", "<Plug>(coc-snippets-expand-jump)")
			-- Use <c-space> to trigger completion
			keyset("i", "<c-space>", "coc#refresh()", { silent = true, expr = true })

			-- Use `[g` and `]g` to navigate diagnostics
			-- Use `:CocDiagnostics` to get all diagnostics of current buffer in location list
			keyset("n", "[g", "<Plug>(coc-diagnostic-prev)", { silent = true })
			keyset("n", "]g", "<Plug>(coc-diagnostic-next)", { silent = true })

			-- GoTo code navigation
			keyset("n", "gd", "<Plug>(coc-definition)", { silent = true })
			keyset("n", "gy", "<Plug>(coc-type-definition)", { silent = true })
			keyset("n", "gi", "<Plug>(coc-implementation)", { silent = true })
			keyset("n", "gr", "<Plug>(coc-references)", { silent = true })

			-- Use K or Ctrl-h to show documentation in preview window
			function _G.show_docs()
				local cw = vim.fn.expand("<cword>")
				if vim.fn.index({ "vim", "help" }, vim.bo.filetype) >= 0 then
					vim.api.nvim_command("h " .. cw)
				elseif vim.api.nvim_eval("coc#rpc#ready()") then
					vim.fn.CocActionAsync("doHover")
				else
					vim.api.nvim_command("!" .. vim.o.keywordprg .. " " .. cw)
				end
			end
			keyset("n", "K", "<CMD>lua _G.show_docs()<CR>", { silent = true })
			keyset("n", "<C-h>", "<CMD>lua _G.show_docs()<CR>", { silent = true })

			-- Highlight the symbol and its references on a CursorHold event(cursor is idle)
			vim.api.nvim_create_augroup("CocGroup", {})
			vim.api.nvim_create_autocmd("CursorHold", {
				group = "CocGroup",
				command = "silent call CocActionAsync('highlight')",
				desc = "Highlight symbol under cursor on CursorHold",
			})

			-- Symbol renaming
			keyset("n", "<leader>rn", "<Plug>(coc-rename)", { silent = true })

			-- Setup formatexpr specified filetype(s)
			vim.api.nvim_create_autocmd("FileType", {
				group = "CocGroup",
				pattern = "typescript,json",
				command = "setl formatexpr=CocAction('formatSelected')",
				desc = "Setup formatexpr specified filetype(s).",
			})

			-- Update signature help on jump placeholder
			vim.api.nvim_create_autocmd("User", {
				group = "CocGroup",
				pattern = "CocJumpPlaceholder",
				command = "call CocActionAsync('showSignatureHelp')",
				desc = "Update signature help on jump placeholder",
			})

			-- Remap <C-f> and <C-b> to scroll float windows/popups
			---@diagnostic disable-next-line: redefined-local
			local opts = { silent = true, nowait = true, expr = true }
			keyset("n", "<C-f>", 'coc#float#has_scroll() ? coc#float#scroll(1) : "<C-f>"', opts)
			keyset("n", "<C-b>", 'coc#float#has_scroll() ? coc#float#scroll(0) : "<C-b>"', opts)
			keyset("i", "<C-f>", 'coc#float#has_scroll() ? "<c-r>=coc#float#scroll(1)<cr>" : "<Right>"', opts)
			keyset("i", "<C-b>", 'coc#float#has_scroll() ? "<c-r>=coc#float#scroll(0)<cr>" : "<Left>"', opts)
			keyset("v", "<C-f>", 'coc#float#has_scroll() ? coc#float#scroll(1) : "<C-f>"', opts)
			keyset("v", "<C-b>", 'coc#float#has_scroll() ? coc#float#scroll(0) : "<C-b>"', opts)

			-- Add `:Format` command to format current buffer
			vim.api.nvim_create_user_command("Format", "call CocAction('format')", {})

			-- " Add `:Fold` command to fold current buffer
			vim.api.nvim_create_user_command("Fold", "call CocAction('fold', <f-args>)", { nargs = "?" })

			-- Add (Neo)Vim's native statusline support
			-- NOTE: Please see `:h coc-status` for integrations with external plugins that
			-- provide custom statusline: lightline.vim, vim-airline
			vim.opt.statusline:prepend("%{coc#status()}%{get(b:,'coc_current_function','')}")

			vim.api.nvim_set_var("coc_global_extensions", {
				"coc-cfn-lint",
				"coc-docker",
				"coc-eslint",
				"coc-highlight",
				"coc-jedi",
				"coc-json",
				"coc-lists",
				"coc-lua",
				"coc-prettier",
				"coc-pyright",
				"coc-rls",
				"coc-rust-analyzer",
				"coc-sh",
				-- "coc-snippets",
				--"coc-sql",
				"coc-sqlfluff",
				"coc-toml",
				"coc-tsserver",
				"coc-xml",
				"coc-yaml",
				"@yaegassy/coc-pysen",
				--"@yaegassy/coc-ruff",
			})

			vim.api.nvim_create_user_command("EnableCocFormat", function()
				local id = vim.api.nvim_create_augroup("cocfmt", {})
				vim.api.nvim_create_autocmd({ "BufWritePre" }, {
					pattern = { "*" },
					command = "CocCommand prettier.forceFormatDocument",
					group = id,
				})
			end, {})
			vim.api.nvim_create_user_command("DisableCocFormat", function()
				vim.api.nvim_del_augroup_by_name("cocfmt")
			end, {})
		end,
	},
	-- Preview results from coc.nvim
	{
		"fannheyward/telescope-coc.nvim",
		enabled = false,
		dependencies = { "neoclide/coc.nvim", "nvim-telescope/telescope.nvim" },
		event = "VeryLazy",
		config = function()
			require("telescope").setup({
				extensions = {
					coc = {
						theme = "ivy",
						prefer_locations = true, -- always use Telescope locations to preview definitions/declarations/implementations etc
					},
				},
			})
			require("telescope").load_extension("coc")
			vim.api.nvim_set_keymap("n", "gd", "<Cmd>Telescope coc definitions<CR>", { noremap = true })
			-- vim.api.nvim_set_keymap("n", "gp", "<Cmd>Telescope coc type_definitions<CR>", { noremap = true })
			vim.api.nvim_set_keymap("n", "gi", "<Cmd>Telescope coc implementations<CR>", { noremap = true })
			vim.api.nvim_set_keymap("n", "gr", "<Cmd>Telescope coc references<CR>", { noremap = true })
			vim.api.nvim_set_keymap("n", "ge", "<Cmd>Telescope coc diagnostics<CR>", { noremap = true })
		end,
	},
}
