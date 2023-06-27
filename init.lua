local api = vim.api
local fn = vim.fn
local opt = vim.opt

local home_dir = api.nvim_eval("$HOME")

api.nvim_set_var("python3_host_prog", string.format("%s/.pyenv/versions/neovim3/bin/python", home_dir))
api.nvim_set_var("python_host_prog", string.format("%s/.pyenv/versions/neovim2/bin/python", home_dir))

local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
	packer_bootstrap = fn.system({
		"git",
		"clone",
		"--depth",
		"1",
		"https://github.com/wbthomason/packer.nvim",
		install_path,
	})
end

-- # keymapping #
vim.g.mapleader = " "
-- ## insert mode ##
api.nvim_set_keymap("i", "jj", "<ESC>", { noremap = true })
-- move cursor
api.nvim_set_keymap("i", "<C-j>", "<down>", { noremap = true })
api.nvim_set_keymap("i", "<C-k>", "<up>", { noremap = true })
api.nvim_set_keymap("i", "<C-h>", "<left>", { noremap = true })
api.nvim_set_keymap("i", "<C-l>", "<right>", { noremap = true })
api.nvim_set_keymap("n", "<S-h>", "^", { noremap = true })
api.nvim_set_keymap("n", "<S-l>", "$", { noremap = true })
-- ## normal mode ##
api.nvim_set_keymap("n", ";", ":", { noremap = true })
-- delete without yanking
api.nvim_set_keymap("n", "d", '"_d', { noremap = true })
-- move cursor
api.nvim_set_keymap("n", "s", "<Nop>", { noremap = true })
api.nvim_set_keymap("n", "sj", "<C-w>j", { noremap = true })
api.nvim_set_keymap("n", "sk", "<C-w>k", { noremap = true })
api.nvim_set_keymap("n", "sh", "<C-w>h", { noremap = true })
api.nvim_set_keymap("n", "sl", "<C-w>l", { noremap = true })
-- move window
api.nvim_set_keymap("n", "sJ", "<C-w>J", { noremap = true })
api.nvim_set_keymap("n", "sK", "<C-w>K", { noremap = true })
api.nvim_set_keymap("n", "sH", "<C-w>H", { noremap = true })
api.nvim_set_keymap("n", "sL", "<C-w>L", { noremap = true })
-- api.nvim_set_keymap("n", "sw", "<C-w>_<C-w>|", { noremap = true })
-- api.nvim_set_keymap("n", "sW", "<C-w>", { noremap = true })
-- buffer operations
api.nvim_set_keymap("n", "<Leader>bp", "<Cmd>bprevious<CR>", { noremap = true })
api.nvim_set_keymap("n", "<Leader>bn", "<Cmd>bnext<CR>", { noremap = true })
api.nvim_set_keymap("n", "<Leader>bb", "<Cmd>b#<CR>", { noremap = true })
api.nvim_set_keymap("n", "<Leader>bd", "<Cmd>bdelete<CR>", { noremap = true })
-- search and replace
api.nvim_set_keymap("n", "<Leader>F", [["zyiw:let @/ = '\<' . @z . '\>'<CR>:set hlsearch<CR>]], { noremap = true })
api.nvim_set_keymap("n", "<Leader>r", [[<Leader>f:%s/<C-r>///g<Left><Left>]], { noremap = false })
api.nvim_set_keymap("n", "<Esc><Esc>", "<Cmd>set nohlsearch!<CR>", { noremap = true })
api.nvim_set_keymap("n", "/", "/\\v", { noremap = false })
-- ## visual mode ##
-- move cursor
api.nvim_set_keymap("x", "<S-h>", "^", { noremap = true })
api.nvim_set_keymap("x", "<S-l>", "$", { noremap = true })
-- paste without yanking
api.nvim_set_keymap("x", "p", '"_xP', { noremap = true })
-- ## terminal mode ##
api.nvim_set_keymap("t", "<esc>", [[<C-\><C-n>]], { noremap = true })
api.nvim_set_keymap("t", "jj", [[<C-\><C-n>]], { noremap = true })
api.nvim_set_keymap("t", "<C-h>", [[<C-\><C-n><C-W>h]], { noremap = true })
api.nvim_set_keymap("t", "<C-j>", [[<C-\><C-n><C-W>j]], { noremap = true })
api.nvim_set_keymap("t", "<C-k>", [[<C-\><C-n><C-W>k]], { noremap = true })
api.nvim_set_keymap("t", "<C-l>", [[<C-\><C-n><C-W>l]], { noremap = true })

-- # option #
opt.hidden = true
-- tab
opt.expandtab = true
opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 4
opt.autoindent = true
opt.smartindent = true

-- serach
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true

-- cursor
opt.number = true
opt.cursorline = true
opt.cursorcolumn = false
opt.showmatch = true
opt.ruler = true

-- file
opt.swapfile = false
opt.autoread = true
opt.backup = false
opt.writebackup = false

-- line
opt.whichwrap = "b,s,h,l,<,>,[,]"

-- scroll
opt.scrolloff = 12
opt.sidescrolloff = 16
opt.sidescroll = 1

-- blank
opt.backspace = { "indent", "eol", "start" }
opt.list = true

-- sourd
opt.visualbell = false
opt.errorbells = false

-- other settings
opt.cmdheight = 2
opt.laststatus = 2

-- clipboard
opt.clipboard:append("unnamedplus")

-- color schema
opt.syntax = "on"

-- shell
opt.sh = "zsh"

-- # autocmd # --
-- open quickfix
-- vim.cmd("autocmd QuickFixCmdPost *grep* cwindow")
-- vim.cmd('autocmd BufWritePost *.py ')
-- vim.cmd('autocmd!')
-- vim.cmd('autocmd!')

-- vim.cmd [[packadd packer.nvim]]

require("packer").startup(function(use)
	-- ### Package Manager ###
	use("wbthomason/packer.nvim")

	-- ### Apperance ###
	-- color schema
	use({
		"cocopon/iceberg.vim",
		config = function()
			vim.cmd([[
                set t_Co=256
                colorscheme iceberg
                filetype plugin indent on
            ]])
		end,
	})
	-- status/tabline
	use({
		"vim-airline/vim-airline",
		requires = { "vim-airline/vim-airline-themes" },
		config = function()
			vim.api.nvim_set_var("airline_theme", "iceberg")
		end,
	})
	-- resize window
	use({ "simeji/winresizer" })
	-- indent
	use({
		"lukas-reineke/indent-blankline.nvim",
		requires = { "nvim-treesitter/nvim-treesitter" },
		config = function()
			vim.opt.list = true
			vim.opt.listchars:append("space:⋅")
			vim.opt.listchars:append("eol:↴")

			require("indent_blankline").setup({
				space_char_blankline = " ",
				show_current_context = true,
				show_current_context_start = true,
			})
		end,
	})
	-- ### Finder ###
	-- file finder
	use({
		"nvim-telescope/telescope.nvim",
		requires = { { "nvim-lua/plenary.nvim" } },
		setup = function()
			vim.api.nvim_set_keymap("n", "sd", "<Cmd>Telescope buffers<CR>", { noremap = true })
			vim.api.nvim_set_keymap("n", "sf", "<Cmd>Telescope find_files<CR>", { noremap = true })
			vim.api.nvim_set_keymap("n", "sg", "<Cmd>Telescope git_files<CR>", { noremap = true })
			vim.api.nvim_set_keymap("n", "sc", "<Cmd>Telescope live_grep<CR>", { noremap = true })
			vim.api.nvim_set_keymap("n", "so", "<Cmd>Telescope oldfiles<CR>", { noremap = true })
			-- list vimwiki files
			vim.api.nvim_set_keymap(
				"n",
				"sw",
				"<Cmd>Telescope find_files cwd=$HOME/vimwiki/data<CR>",
				{ noremap = true, silent = true }
			)
		end,
	})
	-- calculating matching score for telescope
	use({
		"nvim-telescope/telescope-fzf-native.nvim",
		requires = { "nvim-telescope/telescope.nvim" },
		run = "make",
		config = function()
			require("telescope").setup({})
			require("telescope").load_extension("fzf")
		end,
	})
	-- intelligent prioritization for telescope
	use({
		"nvim-telescope/telescope-frecency.nvim",
		requires = { "tami5/sqlite.lua" },
		config = function()
			require("telescope").load_extension("frecency")
			vim.api.nvim_set_keymap(
				"n",
				"sp",
				"<Cmd>lua require('telescope').extensions.frecency.frecency()<CR>",
				{ noremap = true, silent = true }
			)
		end,
	})
	-- command line finder
	-- use({ "ibhagwan/fzf-lua", requires = { "kyazdani42/nvim-web-devicons" } })
	use({
		"junegunn/fzf.vim",
		run = function()
			vim.fn["fzf#install"]()
		end,
	})
	-- ### Viewer ###
	use({
		"nvim-treesitter/nvim-treesitter",
		run = "TSUpdate",
		config = function()
			require("nvim-treesitter.configs").setup({
				ensure_installed = "all",
				highlight = {
					enable = true,
					disable = {},
				},
				indent = {
					enable = false,
				},
			})
		end,
	})
	-- explorer
	use({
		"kyazdani42/nvim-tree.lua",
		requires = {
			"kyazdani42/nvim-web-devicons", -- optional, for file icon
		},
		setup = function()
			vim.api.nvim_set_keymap("n", "<Leader>t", "<Cmd>NvimTreeToggle<CR>", { noremap = true })
			vim.api.nvim_set_keymap("n", "<Leader>T", "<Cmd>NvimTreeRefresh<CR>", { noremap = true })
			vim.api.nvim_set_keymap("n", "<Leader>n", "<Cmd>NvimTreeFindFile<CR>", { noremap = true })
			vim.cmd([[set termguicolors]])
		end,
		config = function()
			require("nvim-tree").setup({
				update_cwd = false,
				update_focused_file = {
					enable = true,
					update_root = true,
				},
				git = {
					ignore = false,
				},
				view = {
					width = 40,
					mappings = {
						custom_only = true,
						list = {
							{ key = { "<CR>", "o", "<2-LeftMouse>" }, action = "edit" },
							{ key = "<C-v>", action = "vsplit" },
							{ key = "<C-x>", action = "split" },
							{ key = "<C-t>", action = "tabnew" },
							{ key = "<BS>", action = "close_node" },
							{ key = "<C-r>", action = "refresh" },
							{ key = "a", action = "create" },
							{ key = "d", action = "remove" },
							{ key = "D", action = "trash" },
							{ key = "r", action = "rename" },
							{ key = "x", action = "cut" },
							{ key = "c", action = "copy" },
							{ key = "p", action = "paste" },
							{ key = "y", action = "copy_name" },
							{ key = "Y", action = "copy_absolute_path" },
							{ key = "?", action = "toggle_help" },
						},
					},
				},
			})
		end,
	})
	-- csv
	use({ "chrisbra/csv.vim" })
	-- ### Features ###
	-- terminal
	use({
		"akinsho/toggleterm.nvim",
		tag = "v1.*",
		setup = function()
			vim.api.nvim_set_keymap("n", "<Leader>c", "<Cmd>ToggleTerm<CR>", { noremap = true, silent = true })
		end,
		config = function()
			require("toggleterm").setup({
				shade_terminals = false,
			})
		end,
	})
	-- git
	use({ "airblade/vim-gitgutter" })
	use({ "tpope/vim-fugitive" })
	-- easymotion
	use({
		"Lokaltog/vim-easymotion",
		setup = function()
			vim.api.nvim_set_var("EasyMotion_do_mapping", 0)
			vim.api.nvim_set_keymap("n", "f", "<Plug>(easymotion-overwin-f2)", { noremap = false })
			vim.api.nvim_set_keymap("v", "f", "<Plug>(easymotion-overwin-f2)", { noremap = false })
		end,
	})
	-- greeter to edit most recently used files
	use({
		"goolord/alpha-nvim",
		requires = { "kyazdani42/nvim-web-devicons" },
		config = function()
			require("alpha").setup(require("alpha.themes.startify").config)
		end,
	})
	-- scroll bar
	-- use({
	-- 	"petertriho/nvim-scrollbar",
	-- 	requires = { "lewis6991/gitsigns.nvim" },
	-- 	config = function()
	-- 		require("scrollbar.handlers.search").setup({
	-- 			-- hlslens config overrides
	-- 		})
	-- 		require("gitsigns").setup()
	-- 		require("scrollbar.handlers.gitsigns").setup()
	-- 	end,
	-- })
	-- show matched information
	use({
		"kevinhwang91/nvim-hlslens",
		config = function()
			require("hlslens").setup()
			local kopts = { noremap = true, silent = true }

			vim.api.nvim_set_keymap(
				"n",
				"n",
				[[<Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>]],
				kopts
			)
			vim.api.nvim_set_keymap(
				"n",
				"N",
				[[<Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>]],
				kopts
			)
			vim.api.nvim_set_keymap("n", "*", [[*<Cmd>lua require('hlslens').start()<CR>]], kopts)
			vim.api.nvim_set_keymap("n", "#", [[#<Cmd>lua require('hlslens').start()<CR>]], kopts)
			vim.api.nvim_set_keymap("n", "g*", [[g*<Cmd>lua require('hlslens').start()<CR>]], kopts)
			vim.api.nvim_set_keymap("n", "g#", [[g#<Cmd>lua require('hlslens').start()<CR>]], kopts)

			vim.api.nvim_set_keymap("n", "<Leader>l", "<Cmd>noh<CR>", kopts)
		end,
	})
	-- show line diff
	use({ "AndrewRadev/linediff.vim" })
	-- show git diff
	use({ "sindrets/diffview.nvim", requires = "nvim-lua/plenary.nvim" })
	-- dotenv
	use({ "tpope/vim-dotenv" })

	-- autocomplete brackets
	use({ "jiangmiao/auto-pairs" })

	-- cheetsheet
	use({
		"sudormrfbin/cheatsheet.nvim",
		requires = {
			"nvim-telescope/telescope.nvim",
			"nvim-lua/popup.nvim",
			"nvim-lua/plenary.nvim",
		},
		config = function()
			vim.api.nvim_set_keymap("n", "<leader>s", "<Cmd>Cheatsheet<CR>", { noremap = true, silent = true })
			require("cheatsheet").setup({
				-- Whether to show bundled cheatsheets
				-- For generic cheatsheets like default, unicode, nerd-fonts, etc
				-- bundled_cheatsheets = {
				--     enabled = {},
				--     disabled = {},
				-- },
				bundled_cheatsheets = false,

				-- For plugin specific cheatsheets
				-- bundled_plugin_cheatsheets = {
				--     enabled = {},
				--     disabled = {},
				-- }
				bundled_plugin_cheatsheets = true,

				-- For bundled plugin cheatsheets, do not show a sheet if you
				-- don't have the plugin installed (searches runtimepath for
				-- same directory name)
				include_only_installed_plugins = true,

				-- Key mappings bound inside the telescope window
				telescope_mappings = {
					["<CR>"] = require("cheatsheet.telescope.actions").select_or_fill_commandline,
					["<C-CR>"] = require("cheatsheet.telescope.actions").select_or_execute,
					["<C-Y>"] = require("cheatsheet.telescope.actions").copy_cheat_value,
					["<C-E>"] = require("cheatsheet.telescope.actions").edit_user_cheatsheet,
				},
			})
		end,
	})
	-- snippet
	use({ "honza/vim-snippets" })

	-- formatter
	use({
		"sbdchd/neoformat",
		config = function()
			vim.api.nvim_create_user_command("EnableNeoFormat", function()
				local id = vim.api.nvim_create_augroup("neofmt", {})
				vim.api.nvim_create_autocmd({ "BufWritePre" }, {
					pattern = { "*" },
					command = "undojoin | Neoformat",
					group = id,
				})
			end, {})
			vim.api.nvim_create_user_command("DisableNeoFormat", function()
				vim.api.nvim_del_augroup_by_name("neofmt")
			end, {})
			vim.api.nvim_command("EnableNeoFormat")
			-- for zsh
			vim.api.nvim_set_var("shfmt_opt", "-ci")
			-- for markdown
			vim.api.nvim_set_keymap(
				"n",
				"<leader>fmd",
				"<Cmd>Neoformat! markdown<CR>",
				{ noremap = true, silent = true }
			)
		end,
	})
	-- IDE
	use({
		"neoclide/coc.nvim",
		branch = "release",
		setup = function()
			vim.cmd([[
                " May need for Vim (not Neovim) since coc.nvim calculates byte offset by count
                " utf-8 byte sequence
                set encoding=utf-8
                " Some servers have issues with backup files, see #649
                set nobackup
                set nowritebackup
                
                " Having longer updatetime (default is 4000 ms = 4s) leads to noticeable
                " delays and poor user experience
                set updatetime=300
                
                " Always show the signcolumn, otherwise it would shift the text each time
                " diagnostics appear/become resolved
                set signcolumn=yes
                
                " Use tab for trigger completion with characters ahead and navigate
                " NOTE: There's always complete item selected by default, you may want to enable
                " no select by `"suggest.noselect": true` in your configuration file
                " NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
                " other plugin before putting this into your config
                inoremap <silent><expr> <TAB>
                      \ coc#pum#visible() ? coc#pum#next(1) :
                      \ CheckBackspace() ? "\<Tab>" :
                      \ coc#refresh()
                inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"
                
                " Make <CR> to accept selected completion item or notify coc.nvim to format
                " <C-g>u breaks current undo, please make your own choice
                inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"
                
                function! CheckBackspace() abort
                  let col = col('.') - 1
                  return !col || getline('.')[col - 1]  =~# '\s'
                endfunction
                
                " Use <c-space> to trigger completion
                if has('nvim')
                  inoremap <silent><expr> <c-space> coc#refresh()
                else
                  inoremap <silent><expr> <c-@> coc#refresh()
                endif
                
                " Use `[g` and `]g` to navigate diagnostics
                " Use `:CocDiagnostics` to get all diagnostics of current buffer in location list
                nmap <silent> [g <Plug>(coc-diagnostic-prev)
                nmap <silent> ]g <Plug>(coc-diagnostic-next)
                
                " GoTo code navigation
                nmap <silent> gd <Plug>(coc-definition)
                nmap <silent> gy <Plug>(coc-type-definition)
                nmap <silent> gi <Plug>(coc-implementation)
                nmap <silent> gr <Plug>(coc-references)
                
                " Use K to show documentation in preview window
                nnoremap <silent> K :call ShowDocumentation()<CR>
                
                function! ShowDocumentation()
                  if CocAction('hasProvider', 'hover')
                    call CocActionAsync('doHover')
                  else
                    call feedkeys('K', 'in')
                  endif
                endfunction
                
                " Highlight the symbol and its references when holding the cursor
                autocmd CursorHold * silent call CocActionAsync('highlight')
                
                " Symbol renaming
                nmap <leader>rn <Plug>(coc-rename)
                
                " Formatting selected code
                xmap <leader>f  <Plug>(coc-format-selected)
                nmap <leader>f  <Plug>(coc-format-selected)
                
                augroup mygroup
                  autocmd!
                  " Setup formatexpr specified filetype(s)
                  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
                  " Update signature help on jump placeholder
                  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
                augroup end
                
                " Applying code actions to the selected code block
                " Example: `<leader>aap` for current paragraph
                xmap <leader>a  <Plug>(coc-codeaction-selected)
                nmap <leader>a  <Plug>(coc-codeaction-selected)
                
                " Remap keys for applying code actions at the cursor position
                nmap <leader>ac  <Plug>(coc-codeaction-cursor)
                " Remap keys for apply code actions affect whole buffer
                nmap <leader>as  <Plug>(coc-codeaction-source)
                " Apply the most preferred quickfix action to fix diagnostic on the current line
                nmap <leader>qf  <Plug>(coc-fix-current)
                
                " Remap keys for applying refactor code actions
                nmap <silent> <leader>re <Plug>(coc-codeaction-refactor)
                xmap <silent> <leader>r  <Plug>(coc-codeaction-refactor-selected)
                nmap <silent> <leader>r  <Plug>(coc-codeaction-refactor-selected)
                
                " Run the Code Lens action on the current line
                nmap <leader>cl  <Plug>(coc-codelens-action)
                
                " Map function and class text objects
                " NOTE: Requires 'textDocument.documentSymbol' support from the language server
                xmap if <Plug>(coc-funcobj-i)
                omap if <Plug>(coc-funcobj-i)
                xmap af <Plug>(coc-funcobj-a)
                omap af <Plug>(coc-funcobj-a)
                xmap ic <Plug>(coc-classobj-i)
                omap ic <Plug>(coc-classobj-i)
                xmap ac <Plug>(coc-classobj-a)
                omap ac <Plug>(coc-classobj-a)
                
                " Remap <C-f> and <C-b> to scroll float windows/popups
                if has('nvim-0.4.0') || has('patch-8.2.0750')
                  nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
                  nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
                  inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
                  inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
                  vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
                  vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
                endif
                
                " Use CTRL-S for selections ranges
                " Requires 'textDocument/selectionRange' support of language server
                " nmap <silent> <C-s> <Plug>(coc-range-select)
                " xmap <silent> <C-s> <Plug>(coc-range-select)
                
                " Add `:Format` command to format current buffer
                command! -nargs=0 Format :call CocActionAsync('format')
                
                " Add `:Fold` command to fold current buffer
                command! -nargs=? Fold :call     CocAction('fold', <f-args>)
                
                " Add `:OR` command for organize imports of the current buffer
                command! -nargs=0 OR   :call     CocActionAsync('runCommand', 'editor.action.organizeImport')
                
                " Add (Neo)Vim's native statusline support
                " NOTE: Please see `:h coc-status` for integrations with external plugins that
                " provide custom statusline: lightline.vim, vim-airline
                set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}
                
                " Mappings for CoCList
                " Show all diagnostics
                nnoremap <silent><nowait> <space>a  :<C-u>CocList diagnostics<cr>
                " Manage extensions
                nnoremap <silent><nowait> <space>e  :<C-u>CocList extensions<cr>
                " Show commands
                nnoremap <silent><nowait> <space>c  :<C-u>CocList commands<cr>
                " Find symbol of current document
                nnoremap <silent><nowait> <space>o  :<C-u>CocList outline<cr>
                " Search workspace symbols
                nnoremap <silent><nowait> <space>s  :<C-u>CocList -I symbols<cr>
                " Do default action for next item
                nnoremap <silent><nowait> <space>j  :<C-u>CocNext<CR>
                " Do default action for previous item
                nnoremap <silent><nowait> <space>k  :<C-u>CocPrev<CR>
                " Resume latest coc list
                nnoremap <silent><nowait> <space>p  :<C-u>CocListResume<CR>

            ]])
			-- add default extensions
			vim.api.nvim_set_var("coc_global_extensions", {
				"coc-lists",
				"coc-highlight",
				"coc-json",
				"coc-yaml",
				"coc-pyright",
				"coc-jedi",
				"coc-cfn-lint",
				"coc-sh",
				"coc-rls",
				"coc-rust-analyzer",
				"@yaegassy/coc-pysen",
				"coc-tsserver",
				"coc-eslint",
				"coc-prettier",
				"coc-react-refactor",
			})

			-- Additional settings
			vim.opt.updatetime = 50
			local keyset = vim.keymap.set
			-- Use Ctrl-h (or K) to show documentation in preview window.
			keyset("n", "<C-h>", ":<C-u>CocActionAsync('doHover')<CR>", { silent = true })
			keyset("i", "<C-h>", ":<C-u>CocActionAsync('doHover')<CR>", { silent = true })
			-- Use Ctrl-p to show parameter hint
			keyset("n", "<C-p>", ":<C-u>CocActionAsync('showSignatureHelp')<CR>", { silent = true })
			keyset("i", "<C-p>", ":<C-u>CocActionAsync('showSignatureHelp')<CR>", { silent = true })

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
	})
	-- preview results from coc.nvim
	use({
		"fannheyward/telescope-coc.nvim",
		requires = { "neoclide/coc.nvim", "nvim-telescope/telescope.nvim" },
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
	})
	-- wiki
	use({
		"vimwiki/vimwiki",
		setup = function()
			vim.cmd([[
                set nocompatible
                filetype plugin on
                syntax on
            ]])
			vim.api.nvim_set_var("vimwiki_list", {
				{
					path = "~/vimwiki/data",
					syntax = "markdown",
					ext = "md",
					auto_tags = 1,
					auto_diary_index = 1,
					auto_generate_tags = 1,
					auto_toc = 1,
				},
			})
			vim.api.nvim_set_var("vimwiki_global_ext", 1)
			vim.api.nvim_set_var("vimwiki_markdown_link_ext", 1)
			vim.api.nvim_set_var("taskwiki_markup_syntax", "markdown")
			vim.api.nvim_set_var("markdown_folding", 1)

			-- register markdown files to vimwiki
			vim.api.nvim_set_var("vimwiki_filetypes", { "markdown" })
			-- disable key mappings
			vim.api.nvim_set_var("vimwiki_key_mappings", { all_maps = 0 })
		end,
	})
	-- task management
	use({
		"tools-life/taskwiki",
		requires = { "vimwiki/vimwiki" },
		config = function()
			vim.api.nvim_set_keymap("n", "td", "<Cmd>TaskWikiDone<CR>", { noremap = true, silent = true })
			vim.api.nvim_set_keymap("n", "tdd", "<Cmd>TaskWikiDelete<CR>", { noremap = true, silent = true })
			vim.api.nvim_set_keymap("n", "tt", "<Cmd>TaskWikiToggle<CR>", { noremap = true, silent = true })
			vim.api.nvim_set_keymap("n", "te", "<Cmd>TaskWikiEdit<CR>", { noremap = true, silent = true })
			vim.api.nvim_set_keymap("n", "tm", "<Cmd>TaskWikiMod<CR>", { noremap = true, silent = true })
			-- TODO: add shell script to sync TW task to Google Calendar
			vim.api.nvim_set_keymap(
				"n",
				"ts",
				"<Cmd>silent !$HOME/vimwiki/data/todo/sync_task_with_calendar.sh<CR>",
				{ noremap = true, silent = true }
			)
		end,
	})
	-- save and restore vim session
	use({
		"rmagatti/auto-session",
		config = function()
			require("auto-session").setup({
				log_level = "info",
				auto_session_enabled = true,
				auto_session_allowed_dirs = { "~/vimwiki/data/" },
			})
		end,
	})
	-- # Lazy loading plugins #
	-- quickfix
	use({
		"kevinhwang91/nvim-bqf",
		ft = "qf",
		requires = { "junegunn/fzf.vim", "nvim-treesitter/nvim-treesitter" },
	})
	-- markdown mappings for folding
	use({
		"preservim/vim-markdown",
		requires = { "godlygeek/tabular" },
		setup = function()
			vim.api.nvim_set_var("vim_markdown_folding_disabled", 1)
		end,
	})

	-- markdown preview
	use({
		"ellisonleao/glow.nvim",
		branch = "main",
		ft = { "markdown" },
		config = function()
			vim.api.nvim_set_keymap("n", "<leader>p", "<Cmd>Glow<CR>", { noremap = true, silent = true })
		end,
	})
	-- taskwiki plugins
	use({ "powerman/vim-plugin-AnsiEsc" })
	use({ "preservim/tagbar" })
	use({
		"blindFS/vim-taskwarrior",
		config = function()
			vim.api.nvim_set_keymap("n", "tw", "<Cmd>TW<CR>", { noremap = true, silent = true })
		end,
	})
	-- python
	use({
		"lambdalisue/vim-pyenv",
		ft = { "python" },
	})
	-- rust
	use({
		"rust-lang/rust.vim",
		ft = { "rust" },
		setup = function()
			vim.api.nvim_set_var("rustfmt_autosave", 1)
		end,
	})
	-- jupyter
	use({
		"goerz/jupytext.vim",
		ft = { "python", "ipynb" },
		setup = function()
			vim.cmd([[
                execute 'source' '~/.local/share/nvim/site/pack/packer/opt/jupytext.vim/plugin/jupytext.vim'
            ]])
			vim.api.nvim_set_var("jupytext_enable", 1)
			vim.api.nvim_set_var("jupytext_fmt", "py:percent")
			vim.api.nvim_set_var("jupytext_filetype_map", '{"py": "python"}')
			vim.api.nvim_set_var("jupytext_command", "~/.pyenv/versions/neovim3/bin/jupytext")
		end,
	})
	-- convert sql keywords to upper case
	use({ "jsborjesson/vim-uppercase-sql", ft = { "sql" } })
	-- sql workspace
	use({
		"kristijanhusak/vim-dadbod-ui",
		requires = { "kristijanhusak/vim-dadbod" },
		ft = { "sql", "markdown" },
	})
	use({
		"kristijanhusak/vim-dadbod",
		setup = function()
			vim.api.nvim_set_var("db_ui_dotenv_variable_prefix", "DB_UI_")
		end,
	})
	-- debugger
	use({
		"rcarriga/nvim-dap-ui",
		requires = {
			"mfussenegger/nvim-dap",
			"mfussenegger/nvim-dap-python",
			"theHamsta/nvim-dap-virtual-text",
		},
		ft = { "python" },
		config = function()
			local dap = require("dap")
			local dapui = require("dapui")
			local dappython = require("dap-python")
			dapui.setup()
			require("nvim-dap-virtual-text").setup()
			-- icons
			vim.fn.sign_define("DapBreakpoint", { text = "⛔", texthl = "", linehl = "", numhl = "" })
			vim.fn.sign_define("DapStopped", { text = "👉", texthl = "", linehl = "", numhl = "" })
			-- open and close windows automatically
			dap.listeners.after.event_initialized["dapui_config"] = function()
				dapui.open()
			end
			dap.listeners.before.event_terminated["dapui_config"] = function()
				dapui.close()
			end
			dap.listeners.before.event_exited["dapui_config"] = function()
				dapui.close()
			end
			-- NOTE: tmp copied from nvim-dap-python
			dappython.setup(string.format("%s/.pyenv/versions/neovim3/bin/python", vim.api.nvim_eval("$HOME")))
			dappython.test_runner = "pytest"
			dap.adapters.python = {
				type = "executable",
				command = string.format("%s/.pyenv/versions/neovim3/bin/python", vim.api.nvim_eval("$HOME")),
				args = { "-m", "debugpy.adapter" },
			}
			dap.configurations.python = {
				{
					type = "python",
					request = "launch",
					name = "Python launch configurations",
					program = "${file}",
				},
			}
			-- Toggle debugger Shift-F12 -> d
			vim.api.nvim_set_keymap(
				"n",
				"<S-F12>",
				":lua require('dapui').toggle()<CR>",
				{ noremap = true, silent = true }
			)
			-- Test method -> <Leader>tm
			vim.api.nvim_set_keymap(
				"n",
				"<Leader>tm",
				":lua require('dap-python').test_method()<CR>",
				{ noremap = true, silent = true }
			)
			-- Continue: Shift-F5 -> c
			vim.api.nvim_set_keymap(
				"n",
				"<S-F5>",
				":lua require('dap').continue()<CR>",
				{ noremap = true, silent = true }
			)
			-- Stop(Quit): Shift-F4 -> q
			vim.api.nvim_set_keymap(
				"n",
				"<S-F4>",
				":lua require('dap').terminate()<CR>",
				{ noremap = true, silent = true }
			)
			-- BreakpoiShift-F9 -> b
			vim.api.nvim_set_keymap(
				"n",
				"<S-F9>",
				":lua require('dap').toggle_breakpoint()<CR>",
				{ noremap = true, silent = true }
			)
			-- StepOver(Next): Shift-F10 -> n
			vim.api.nvim_set_keymap(
				"n",
				"<S-F10>",
				":lua require('dap').step_over()<CR>",
				{ noremap = true, silent = true }
			)
			-- StepIn(Step): Shift-F11 -> i/s
			vim.api.nvim_set_keymap(
				"n",
				"<S-F11>",
				":lua require('dap').step_into()<CR>",
				{ noremap = true, silent = true }
			)
			-- StepOut(Return): Shift-F2 -> o/r
			vim.api.nvim_set_keymap(
				"n",
				"<S-F2>",
				":lua require('dap').step_out()<CR>",
				{ noremap = true, silent = true }
			)
			-- list variables: Shift-F3
			vim.api.nvim_set_keymap("n", "<S-F3>", "<Cmd>Telescope dap variables<CR>", { noremap = true })
		end,
	})
	-- Translator
	use({
		"voldikss/vim-translator",
		config = function()
			vim.api.nvim_set_var("translator_target_lang", "en")
			vim.api.nvim_set_keymap("n", "<Leader>l", "<Cmd>TranslateX<CR>", { noremap = true })
		end,
	})
	-- ChatGPT
	use({
		"madox2/vim-ai",
	})
	-- GitHub Copilot
	use({
		"github/copilot.vim",
	})
	-- Package Manager
	if packer_bootstrap then
		require("packer").sync()
	end
end)
