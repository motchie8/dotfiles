local api = vim.api
local fn = vim.fn
local opt = vim.opt

local home_dir = api.nvim_eval('$HOME')

api.nvim_set_var('python3_host_prog', string.format('%s/.pyenv/versions/neovim3/bin/python', home_dir))
api.nvim_set_var('python_host_prog', string.format('%s/.pyenv/versions/neovim2/bin/python', home_dir))

local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
  packer_bootstrap = fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
end

-- # keymapping #
vim.g.mapleader = ' '
-- ## insert mode ##
api.nvim_set_keymap('i', 'jj', '<ESC>', { noremap = true })
-- move cursor
api.nvim_set_keymap('i', '<C-j>', '<down>', { noremap = true })
api.nvim_set_keymap('i', '<C-k>', '<up>', { noremap = true })
api.nvim_set_keymap('i', '<C-h>', '<left>', { noremap = true })
api.nvim_set_keymap('i', '<C-l>', '<right>', { noremap = true })
api.nvim_set_keymap('n', '<S-h>', '^', { noremap = true })
api.nvim_set_keymap('n', '<S-l>', '$', { noremap = true })
-- ## normal mode ##
api.nvim_set_keymap('n', ';', ':', { noremap = true })
-- delete without yanking
api.nvim_set_keymap('n', 'd', '"_d', { noremap = true })
-- move cursor
api.nvim_set_keymap('n', 's', '<Nop>', { noremap = true })
api.nvim_set_keymap('n', 'sj', '<C-w>j', { noremap = true })
api.nvim_set_keymap('n', 'sk', '<C-w>k', { noremap = true })
api.nvim_set_keymap('n', 'sh', '<C-w>h', { noremap = true })
api.nvim_set_keymap('n', 'sl', '<C-w>l', { noremap = true })
-- move window
api.nvim_set_keymap('n', 'sJ', '<C-w>J', { noremap = true })
api.nvim_set_keymap('n', 'sK', '<C-w>K', { noremap = true })
api.nvim_set_keymap('n', 'sH', '<C-w>H', { noremap = true })
api.nvim_set_keymap('n', 'sL', '<C-w>L', { noremap = true })
api.nvim_set_keymap('n', 'sw', '<C-w>_<C-w>|', { noremap = true })
api.nvim_set_keymap('n', 'sW', '<C-w>', { noremap = true })
-- buffer operations
api.nvim_set_keymap('n', '<Leader>bp', '<Cmd>bprevious<CR>', { noremap = true })
api.nvim_set_keymap('n', '<Leader>bn', '<Cmd>bnext<CR>', { noremap = true })
api.nvim_set_keymap('n', '<Leader>bb', '<Cmd>b#<CR>', { noremap = true })
api.nvim_set_keymap('n', '<Leader>bd', '<Cmd>bdelete<CR>', { noremap = true })
-- search and replace
api.nvim_set_keymap('n', '<Leader>f', [["zyiw:let @/ = '\<' . @z . '\>'<CR>:set hlsearch<CR>]], { noremap = true })
api.nvim_set_keymap('n', '<Leader>r', [[<Leader>f:%s/<C-r>///g<Left><Left>]], {noremap = false})
api.nvim_set_keymap('n', '<Esc><Esc>', '<Cmd>set nohlsearch!<CR>', { noremap = true })
-- ## visual mode ##
-- move cursor
api.nvim_set_keymap('x', '<S-h>', '^', { noremap = true })
api.nvim_set_keymap('x', '<S-l>', '$', { noremap = true })
-- paste without yanking
api.nvim_set_keymap('x', 'p', '"_xP', { noremap = true })
-- ## terminal mode ##
api.nvim_set_keymap('t', '<esc>', [[<C-\><C-n>]], { noremap = true })
api.nvim_set_keymap('t', 'jj', [[<C-\><C-n>]], { noremap = true })
api.nvim_set_keymap('t', '<C-h>', [[<C-\><C-n><C-W>h]], { noremap = true })
api.nvim_set_keymap('t', '<C-j>', [[<C-\><C-n><C-W>j]], { noremap = true })
api.nvim_set_keymap('t', '<C-k>', [[<C-\><C-n><C-W>k]], { noremap = true })
api.nvim_set_keymap('t', '<C-l>', [[<C-\><C-n><C-W>l]], { noremap = true })

-- api.nvim_set_keymap('', '', '')

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
opt.swapfile = true
opt.autoread = true
opt.backup = false
opt.writebackup = false

-- line
opt.whichwrap='b,s,h,l,<,>,[,]'

-- scroll
opt.scrolloff = 12
opt.sidescrolloff = 16
opt.sidescroll = 1

-- blank
opt.backspace = {'indent', 'eol', 'start' }
opt.list = true

-- sourd
opt.visualbell = false
opt.errorbells = false

-- other settings
opt.cmdheight = 2
opt.laststatus = 2

-- clipboard
opt.clipboard:append('unnamedplus')

-- color schema
opt.syntax = 'on'

-- shell
opt.sh = 'zsh'

-- vim.cmd [[packadd packer.nvim]]

require('packer').startup(function(use)
  -- ### Package Manager ###
  use 'wbthomason/packer.nvim'

  -- ### Apperance ###
  -- color schema
  use {
    'cocopon/iceberg.vim',
    config = function ()
      vim.cmd([[
        set t_Co=256
        colorscheme iceberg
        filetype plugin indent on
      ]])
    end
  }
  -- status/tabline
  use {
    'vim-airline/vim-airline',
    requires = {'vim-airline/vim-airline-themes'},
    config = function()
      vim.api.nvim_set_var(
        'airline_theme',
        'iceberg'
      )
    end
  }
  -- resize window
  use { 'simeji/winresizer' }
  -- whitespace
  use {
    'ntpeters/vim-better-whitespace',
    setup = function()
      vim.api.nvim_set_var('better_whitespace_enabled', 0)
      vim.api.nvim_set_var('strip_whitespace_on_save', 1)
      vim.api.nvim_set_var('current_line_whitespace_disabled_soft', 1)
    end
  }
  -- indent
  use "lukas-reineke/indent-blankline.nvim"
  -- ### Finder ###
  -- file finder
  use {
    'nvim-telescope/telescope.nvim',
    requires = { {'nvim-lua/plenary.nvim'} },
    setup = function ()
      vim.api.nvim_set_keymap('n', 'sd', '<Cmd>Telescope buffers<CR>', {noremap = true})
      vim.api.nvim_set_keymap('n', 'sf', '<Cmd>Telescope find_files<CR>', {noremap = true})
      vim.api.nvim_set_keymap('n', 'sg', '<Cmd>Telescope live_grep<CR>', {noremap = true})
      vim.api.nvim_set_keymap('n', 'st', '<Cmd>Telescope help_tags<CR>', {noremap = true})
    end
  }
  -- command line finder
  use { 'ibhagwan/fzf-lua',
    requires = { 'kyazdani42/nvim-web-devicons' }
  }
  use {
    'junegunn/fzf.vim',
    requires= {{ 'junegunn/fzf' }}
  }

  -- ### Viewer ###
  use {
    'nvim-treesitter/nvim-treesitter',
    run = 'TSUpdate',
    config = function ()
      require'nvim-treesitter.configs'.setup {
        ensure_installed = "all",
        highlight = {
            enable = true,
            disable = {}
        },
        indent = {
            enable = false
        }
      }
    end
  }
  -- explorer
  use {
    'kyazdani42/nvim-tree.lua',
    requires = {
      'kyazdani42/nvim-web-devicons', -- optional, for file icon
    },
    setup = function ()
      vim.api.nvim_set_keymap('n', '<Leader>t', '<Cmd>NvimTreeToggle<CR>', {noremap = true})
      vim.api.nvim_set_keymap('n', '<Leader>T', '<Cmd>NvimTreeRefresh<CR>', {noremap = true})
      vim.api.nvim_set_keymap('n', '<Leader>n', '<Cmd>NvimTreeFindFile<CR>', {noremap = true})
      vim.cmd([[set termguicolors]])
    end,
    config = function ()
      require'nvim-tree'.setup {
        view = {
          mappings = {
            custom_only = true,
            list = {
              { key = {"<CR>", "o", "<2-LeftMouse>"}, action = "edit" },
              { key = "<C-v>",                        action = "vsplit" },
              { key = "<C-x>",                        action = "split" },
              { key = "<C-t>",                        action = "tabnew" },
              { key = "<BS>",                         action = "close_node" },
              { key = "<C-r>",                        action = "refresh" },
              { key = "a",                            action = "create" },
              { key = "d",                            action = "remove" },
              { key = "D",                            action = "trash" },
              { key = "r",                            action = "rename" },
              { key = "x",                            action = "cut" },
              { key = "c",                            action = "copy" },
              { key = "p",                            action = "paste" },
              { key = "y",                            action = "copy_name" },
              { key = "Y",                            action = "copy_absolute_path" },
              { key = "?",                            action = "toggle_help" },
            },
          },
        },
      }
    end
  }
  -- csv
  use { 'chrisbra/csv.vim' }
  -- ### Features ###
  -- terminal
  use {
    "akinsho/toggleterm.nvim",
    tag = 'v1.*',
    setup = function ()
      vim.api.nvim_set_keymap('n', '<Leader>c', '<Cmd>ToggleTerm<CR>', {noremap = true, silent = true})
    end,
    config = function()
      require"toggleterm".setup{
        shade_terminals = false
      }
    end
  }
  -- use {
  --   'kassio/neoterm',
  --   setup = function()
  --     vim.api.nvim_set_var('neoterm_shell', '&shell')
  --     vim.api.nvim_set_var('neoterm_size', 8)
  --     vim.api.nvim_set_var('neoterm_autoscroll', 1)
  --     vim.api.nvim_set_var('neoterm_repl_python', '&shell')
  --     vim.api.nvim_set_keymap('n', '<Leader>C', '<Cmd>botright Tnew<CR>:T source venv/bin/activate<CR>', {noremap = true})
  --     vim.api.nvim_set_keymap('n', '<Leader>c', '<Cmd>botright Tnew<CR>', {noremap = true, silent = true})
  --     vim.api.nvim_set_keymap('n', '<Leader>e', '<Cmd>TREPLSendLine<CR>', {noremap = true})
  --     vim.api.nvim_set_keymap('t', '<ESC>', '<C-\\><C-n>', {noremap = true})
  --     vim.api.nvim_set_keymap('t', 'jj', '<C-\\><C-n>', {noremap = true})
  --     vim.api.nvim_set_keymap('v', '<Leader>e', 'V:TREPLSendSelection<CR>', {noremap = true})
  --   end
  -- }
  -- git
  use { 'airblade/vim-gitgutter' }
  use { 'tpope/vim-fugitive' }

  -- easymotion
  use {
    'Lokaltog/vim-easymotion',
    setup = function()
      vim.api.nvim_set_var('EasyMotion_do_mapping', 0)
      vim.api.nvim_set_keymap('n', 'f', '<Plug>(easymotion-overwin-f2)', {noremap = false})
    end
  }

  -- dotenv
  use { 'tpope/vim-dotenv' }

  -- autocomplete brackets
  use { 'jiangmiao/auto-pairs' }

  -- cheetsheet
  use {
    'sudormrfbin/cheatsheet.nvim',
    requires = {
      'nvim-telescope/telescope.nvim',
      'nvim-lua/popup.nvim',
      'nvim-lua/plenary.nvim'
    },
    config = function()
      require("cheatsheet").setup({
        -- Whether to show bundled cheatsheets
        -- For generic cheatsheets like default, unicode, nerd-fonts, etc
        -- bundled_cheatsheets = {
        --     enabled = {},
        --     disabled = {},
        -- },
        bundled_cheatsheets = true,

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
            ['<CR>'] = require('cheatsheet.telescope.actions').select_or_fill_commandline,
            ['<A-CR>'] = require('cheatsheet.telescope.actions').select_or_execute,
            ['<C-Y>'] = require('cheatsheet.telescope.actions').copy_cheat_value,
            ['<C-E>'] = require('cheatsheet.telescope.actions').edit_user_cheatsheet
        }
      })
    end
  }
  -- snippet
  use { 'honza/vim-snippets' }

  -- IDE
  use {
    'neoclide/coc.nvim',
    branch = 'release',
    setup = function ()
      -- add default extensions
      vim.api.nvim_set_var(
        'coc_global_extensions',
        {
          'coc-lists',
          'coc-highlight',
          'coc-json',
          'coc-yaml',
          'coc-pyright',
          'coc-jedi',
          'coc-cfn-lint',
          'coc-sh',
          'coc-rls',
          'coc-rust-analyzer',
          '@yaegassy/coc-pysen',
          'coc-tsserver',
          'coc-eslint',
          'coc-prettier',
          'coc-react-refactor'
        }
      )
      vim.cmd([[
        " Set internal encoding of vim, not needed on neovim, since coc.nvim using some
        " unicode characters in the file autoload/float.vim
        set encoding=utf-8

        " TextEdit might fail if hidden is not set.
        set hidden

        " Some servers have issues with backup files, see #649.
        set nobackup
        set nowritebackup

        " Give more space for displaying messages.
        set cmdheight=2

        " Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
        " delays and poor user experience.
        set updatetime=50

        " Don't pass messages to |ins-completion-menu|.
        set shortmess+=c

        " Always show the signcolumn, otherwise it would shift the text each time
        " diagnostics appear/become resolved.
        if has("nvim-0.5.0") || has("patch-8.1.1564")
          " Recently vim can merge signcolumn and number column into one
          set signcolumn=number
        else
          set signcolumn=yes
        endif

        " Use tab for trigger completion with characters ahead and navigate.
        " NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
        " other plugin before putting this into your config.
        inoremap <silent><expr> <TAB>
              \ pumvisible() ? "\<C-n>" :
              \ CheckBackspace() ? "\<TAB>" :
              \ coc#refresh()
        inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

        function! CheckBackspace() abort
          let col = col('.') - 1
          return !col || getline('.')[col - 1]  =~# '\s'
        endfunction

        " Use <c-space> to trigger completion.
        if has('nvim')
          inoremap <silent><expr> <c-space> coc#refresh()
        else
          inoremap <silent><expr> <c-@> coc#refresh()
        endif

        " Make <CR> auto-select the first completion item and notify coc.nvim to
        " format on enter, <cr> could be remapped by other vim plugin
        inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
                                      \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

        " Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
        nmap <silent> <Space>G <Plug>(coc-diagnostic-prev)
        nmap <silent> <Space>g <Plug>(coc-diagnostic-next)

        " GoTo code navigation.
        nmap <silent> gd <Plug>(coc-definition)
        nmap <silent> gy <Plug>(coc-type-definition)
        nmap <silent> gi <Plug>(coc-implementation)
        nmap <silent> gr <Plug>(coc-references)

        " Use K to show documentation in preview window.
        nnoremap <silent> K :call ShowDocumentation()<CR>

        function! ShowDocumentation()
          if CocAction('hasProvider', 'hover')
            call CocActionAsync('doHover')
          else
            call feedkeys('K', 'in')
          endif
        endfunction

        " Highlight the symbol and its references when holding the cursor.
        autocmd CursorHold * silent call CocActionAsync('highlight')

        " Symbol renaming.
        nmap <Space>rn <Plug>(coc-rename)

        " Formatting selected code.
        xmap <Space>fo <Plug>(coc-format-selected)
        nmap <Space>fo  <Plug>(coc-format-selected)

        augroup mygroup
          autocmd!
          " Setup formatexpr specified filetype(s).
          autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
          " Update signature help on jump placeholder.
          autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
        augroup end

        " Applying codeAction to the selected region.
        " Example: `<Space>aap` for current paragraph
        xmap <Space>a  <Plug>(coc-codeaction-selected)
        nmap <Space>a  <Plug>(coc-codeaction-selected)

        " Remap keys for applying codeAction to the current buffer.
        nmap <Space>ac  <Plug>(coc-codeaction)
        " Apply AutoFix to problem on the current line.
        nmap <Space>qf  <Plug>(coc-fix-current)

        " Run the Code Lens action on the current line.
        nmap <Space>cl  <Plug>(coc-codelens-action)

        " Map function and class text objects
        " NOTE: Requires 'textDocument.documentSymbol' support from the language server.
        xmap if <Plug>(coc-funcobj-i)
        omap if <Plug>(coc-funcobj-i)
        xmap af <Plug>(coc-funcobj-a)
        omap af <Plug>(coc-funcobj-a)
        xmap ic <Plug>(coc-classobj-i)
        omap ic <Plug>(coc-classobj-i)
        xmap ac <Plug>(coc-classobj-a)
        omap ac <Plug>(coc-classobj-a)

        " Remap <C-f> and <C-b> for scroll float windows/popups.
        if has('nvim-0.4.0') || has('patch-8.2.0750')
          nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
          nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
          inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
          inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
          vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
          vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
        endif

        " Use CTRL-S for selections ranges.
        " Requires 'textDocument/selectionRange' support of language server.
        nmap <silent> <C-s> <Plug>(coc-range-select)
        xmap <silent> <C-s> <Plug>(coc-range-select)

        " Add `:Format` command to format current buffer.
        command! -nargs=0 Format :call CocActionAsync('format')

        " Add `:Fold` command to fold current buffer.
        command! -nargs=? Fold :call     CocAction('fold', <f-args>)

        " Add `:OR` command for organize imports of the current buffer.
        command! -nargs=0 OR   :call     CocActionAsync('runCommand', 'editor.action.organizeImport')

        " Add (Neo)Vim's native statusline support.
        " NOTE: Please see `:h coc-status` for integrations with external plugins that
        " provide custom statusline: lightline.vim, vim-airline.
        set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

        " Mappings for CoCList
        " Show all diagnostics.
        nnoremap <silent><nowait> <Space>da  :<C-u>CocList diagnostics<cr>
        " Manage extensions.
        "nnoremap <silent><nowait> <space>e  :<C-u>CocList extensions<cr>
        "" Show commands.
        "nnoremap <silent><nowait> <space>c  :<C-u>CocList commands<cr>
        "" Find symbol of current document.
        "nnoremap <silent><nowait> <space>o  :<C-u>CocList outline<cr>
        "" Search workspace symbols.
        "nnoremap <silent><nowait> <space>s  :<C-u>CocList -I symbols<cr>
        "" Do default action for next item.
        "nnoremap <silent><nowait> <space>j  :<C-u>CocNext<CR>
        "" Do default action for previous item.
        "nnoremap <silent><nowait> <space>k  :<C-u>CocPrev<CR>
        "" Resume latest coc list.
        "nnoremap <silent><nowait> <space>p  :<C-u>CocListResume<CR>

        " Use Ctrl-h to show documentation in preview window.
        " nnoremap <silent> <C-h> :call s:show_documentation()<CR>
        nnoremap <silent> <C-h> :call CocActionAsync('doHover')<CR>
        " inoremap <silent> <C-h> :call s:show_documentation()<CR>
        inoremap <silent> <C-h> :call CocActionAsync('doHover')<CR>

        " Use Ctrl-p to show parameter hint
        nnoremap <silent> <C-p> :call CocActionAsync('showSignatureHelp')<CR>
        inoremap <silent> <C-p> :call CocActionAsync('showSignatureHelp')<CR>
      ]])
    end
  }
  -- # Lazy loading plugins #
  -- markdown preview
  use {
    "ellisonleao/glow.nvim",
    branch = 'main',
    ft = {'markdown'}
  }
  -- python
  use {
    'lambdalisue/vim-pyenv',
    ft = {'python'},
  }
  -- rust
  use {
    "rust-lang/rust.vim",
    ft = {'rust'},
    setup = function ()
       vim.api.nvim_set_var('rustfmt_autosave', 1)
    end
  }
  -- jupyter
  use {
    'goerz/jupytext.vim',
    ft = {'python', 'ipynb'},
    setup = function ()
      vim.cmd([[
        execute 'source' '~/.local/share/nvim/site/pack/packer/opt/jupytext.vim/plugin/jupytext.vim'
      ]])
      vim.api.nvim_set_var('jupytext_enable', 1)
      vim.api.nvim_set_var('jupytext_fmt', 'py:percent')
      vim.api.nvim_set_var('jupytext_filetype_map', '{"py": "python"}')
      vim.api.nvim_set_var('jupytext_command', '~/.pyenv/versions/neovim3/bin/jupytext')
    end
  }
  -- sql
  use {
    'kristijanhusak/vim-dadbod-ui',
    requires = {'kristijanhusak/vim-dadbod'},
    ft = {'sql', 'markdown'}
  }
  use {
    'kristijanhusak/vim-dadbod',
    setup = function ()
      vim.api.nvim_set_var('db_ui_dotenv_variable_prefix', 'DB_UI_')
    end
  }
  -- debugger
  use {
    "rcarriga/nvim-dap-ui",
    requires = {
        'mfussenegger/nvim-dap',
        'mfussenegger/nvim-dap-python',
        'theHamsta/nvim-dap-virtual-text'
    },
    ft = { 'python' },
    config = function ()
      local dap = require('dap')
      local dapui = require('dapui')
      local dappython = require('dap-python')
      dapui.setup()
      -- key mappings
      vim.api.nvim_set_keymap('n', '<F12>', ":lua require('dapui').toggle()<CR>", { noremap = true, silent = true })
      -- icons
      vim.fn.sign_define('DapBreakpoint', {text='⛔', texthl='', linehl='', numhl=''})
      vim.fn.sign_define('DapStopped', {text='👉', texthl='', linehl='', numhl=''})
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
      dappython.setup(string.format('%s/.pyenv/versions/neovim3/bin/python', vim.api.nvim_eval('$HOME')))
      dappython.test_runner = 'pytest'
      dap.adapters.python = {
        type = 'executable';
        command = string.format('%s/.pyenv/versions/neovim3/bin/python', vim.api.nvim_eval('$HOME'));
        args = { '-m', 'debugpy.adapter' };
      }
      dap.configurations.python = {
        {
          type = 'python';
          request = 'launch';
          name = 'Python launch configurations';
          program = '${file}';
        }
      }
      -- key mappings
      vim.api.nvim_set_keymap('n', '<Leader>tm', ":lua require('dap-python').test_method()<CR>", { noremap = true, silent = true })
      -- NOTE: tmp coppied from nvim-dap
      vim.api.nvim_set_keymap('n', '<F5>', ":lua require('dap').continue()<CR>", { noremap = true, silent = true })
      vim.api.nvim_set_keymap('n', '<S-F5>', ":lua require('dap').repl.close()<CR>", { noremap = true, silent = true })
      vim.api.nvim_set_keymap('n', '<F9>', ":lua require('dap').toggle_breakpoint()<CR>", { noremap = true, silent = true })
      vim.api.nvim_set_keymap('n', '<F10>', ":lua require('dap').step_over()<CR>", { noremap = true, silent = true })
      vim.api.nvim_set_keymap('n', '<F11>', ":lua require('dap').step_into()<CR>", { noremap = true, silent = true })
      vim.api.nvim_set_keymap('n', '<S-F11>', ":lua require('dap').step_out()<CR>", { noremap = true, silent = true })
    end
  }
  use {
    'nvim-telescope/telescope.nvim',
    requires = {{'mfussenegger/nvim-dap', opt = true}},
    ft = {'python', 'rust'},
    config = function ()
      vim.api.nvim_set_keymap('n', '<F3>', '<Cmd>Telescope dap variables', { noremap = true })
      -- require('telescope').setup()
      -- require('telescope').load_extension('dap')
      -- vim.api.nvim_set_keymap('n', '<Leader>df', '<Cmd>Telescope dap configurations', { noremap = true })
      -- vim.api.nvim_set_keymap('n', '<Leader>db', '<Cmd>Telescope dap list_breakpoints', { noremap = true })
      -- vim.api.nvim_set_keymap('n', '<Leader>dv', '<Cmd>Telescope dap variables', { noremap = true })
      -- vim.api.nvim_set_keymap('n', '<Leader>dF', '<Cmd>Telescope dap frames', { noremap = true })
    end
  }
  -- use {
  --   'puremourning/vimspector',
  --   ft = {'python', 'rust'},
  --   run = function ()
  --     vim.cmd([[
  --       execute './install_gadget.py', '--basedir', '$HOME/.dotfiles/vimspector-config', '--enable-python', '--enable-rust'
  --     ]])
  --   end,
  --   setup = function ()
  --     vim.api.nvim_set_var('vimspector_enable_mappings', 'HUMAN')
  --     vim.api.nvim_set_keymap('n', '<Leader>db', '<Cmd>call vimspector#Launch()<CR>', {noremap = true})
  --     vim.api.nvim_set_keymap('n', '<Leader>di', '<Cmd>VimspectorBalloonEval<CR>', {noremap = false})
  --     vim.api.nvim_set_keymap('x', '<Leader>di', '<Cmd>VimspectorBalloonEval<CR>', {noremap = false})
  --   end
  -- }
  if packer_bootstrap then
    require('packer').sync()
  end
end)
