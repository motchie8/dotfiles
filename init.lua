local api = vim.api
local opt = vim.opt

local pyenv_root = api.nvim_eval("$PYENV_ROOT")

api.nvim_set_var("python3_host_prog", string.format("%s/versions/neovim3/bin/python", pyenv_root))
api.nvim_set_var("python_host_prog", string.format("%s/versions/neovim2/bin/python", pyenv_root))

-- disable netrw due to race conditions at vim startup
api.nvim_set_var("loaded_netrw", 1)
api.nvim_set_var("loaded_netrwPlugin", 1)

-- # keymapping #
vim.g.mapleader = " "
vim.g.maplocalleader = "\\" -- Same for `maplocalleader`

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
--api.nvim_set_keymap("n", "<Leader>R", [[<Leader>f:%s/<C-r>///g<Left><Left>]], { noremap = false })
vim.keymap.set("x", "<leader>R", 'y:%s/<C-r><C-r>"//g<Left><Left>')
vim.keymap.set("n", "<leader>R", 'yiw:%s/<C-r><C-r>"//g<Left><Left>')
api.nvim_set_keymap("n", "<Esc><Esc>", "<Cmd>set nohlsearch!<CR>", { noremap = true })
api.nvim_set_keymap("n", "/", "/\\v", { noremap = false })
-- copy current file path
api.nvim_set_keymap("n", "<Leader>Y", "<Cmd>:let @+=expand('%:p')<CR>", { noremap = true })
api.nvim_set_keymap("n", "cp", "<Cmd>:let @+=expand('%:p')<CR>", { noremap = true })

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

-- search
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
api.nvim_set_option("termguicolors", true)
api.nvim_set_var("&t_8f", "\\<Esc>[38;2;%lu;%lu;%lum")
api.nvim_set_var("&t_8b", "\\<Esc>[48;2;%lu;%lu;%lum")

-- shell
opt.sh = "zsh"

-- # autocmd # --
-- open quickfix
-- vim.cmd("autocmd QuickFixCmdPost *grep* cwindow")
-- vim.cmd('autocmd BufWritePost *.py ')
-- vim.cmd('autocmd!')
-- vim.cmd('autocmd!')

-- Bootstrapping for lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)
require("lazy").setup("plugins")
