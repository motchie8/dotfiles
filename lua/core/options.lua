local api = vim.api
local opt = vim.opt

api.nvim_set_var(
    "python3_host_prog",
    string.format("%s/dotfiles/.venv/bin/python3", api.nvim_eval("$HOME"))
)

-- disable netrw due to race conditions at vim startup
api.nvim_set_var("loaded_netrw", 1)
api.nvim_set_var("loaded_netrwPlugin", 1)

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
opt.listchars = { tab = "▸ ", extends = ">", precedes = "<", nbsp = "+" }

-- sourd
opt.visualbell = false
opt.errorbells = false

-- other settings
opt.cmdheight = 2
-- [avante.nvim] views can only be fully collapsed with the global statusline
opt.laststatus = 3

-- clipboard
opt.clipboard:append("unnamedplus")

-- color schema
opt.syntax = "on"
api.nvim_set_option("termguicolors", true)
api.nvim_set_var("&t_8f", "\\<Esc>[38;2;%lu;%lu;%lum")
api.nvim_set_var("&t_8b", "\\<Esc>[48;2;%lu;%lu;%lum")

-- shell
opt.sh = "zsh"
