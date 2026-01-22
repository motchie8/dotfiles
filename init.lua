local api = vim.api
local opt = vim.opt

-- # keymapping #
api.nvim_set_var("mapleader", " ") -- Set leader key to space
api.nvim_set_var(
    "python3_host_prog",
    string.format("%s/dotfiles/.venv/bin/python3", api.nvim_eval("$HOME"))
)

-- disable netrw due to race conditions at vim startup
api.nvim_set_var("loaded_netrw", 1)
api.nvim_set_var("loaded_netrwPlugin", 1)

-- ## insert mode ##
api.nvim_set_keymap("i", "jj", "<ESC>", { noremap = true })
-- move cursor
-- api.nvim_set_keymap("i", "<C-j>", "<down>", { noremap = true })
-- api.nvim_set_keymap("i", "<C-k>", "<up>", { noremap = true })
-- api.nvim_set_keymap("i", "<C-h>", "<left>", { noremap = true })
-- api.nvim_set_keymap("i", "<C-l>", "<right>", { noremap = true })
api.nvim_set_keymap("n", "<S-h>", "^", { noremap = true })
api.nvim_set_keymap("n", "<S-l>", "$", { noremap = true })

-- ## normal mode ##
api.nvim_set_keymap("n", ";", ":", { noremap = true })
-- delete without yanking
api.nvim_set_keymap("n", "d", '"_d', { noremap = true })
api.nvim_set_keymap("n", "x", '"_d', { noremap = true })
api.nvim_set_keymap("n", "X", '"_D', { noremap = true })
api.nvim_set_keymap("o", "x", "d", { noremap = true })
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
-- buffer operations
api.nvim_set_keymap("n", "<Leader>bp", "<Cmd>bprevious<CR>", { noremap = true })
api.nvim_set_keymap("n", "<Leader>bn", "<Cmd>bnext<CR>", { noremap = true })
api.nvim_set_keymap("n", "<Leader>bb", "<Cmd>b#<CR>", { noremap = true })
api.nvim_set_keymap("n", "<Leader>bd", "<Cmd>bdelete<CR>", { noremap = true })
-- search and replace
api.nvim_set_keymap(
    "n",
    "<Leader>F",
    [["zyiw:let @/ = '\<' . @z . '\>'<CR>:set hlsearch<CR>]],
    { noremap = true }
)
vim.keymap.set("n", "<leader>R", 'yiw:%s/<C-r><C-r>"//g<Left><Left>')
api.nvim_set_keymap("n", "<Esc><Esc>", "<Cmd>set nohlsearch!<CR>", { noremap = true })
api.nvim_set_keymap("n", "/", "/\\v", { noremap = false })
-- copy current file path
api.nvim_set_keymap("n", "<Leader>Y", "<Cmd>:let @+=expand('%:p')<CR>", { noremap = true })
api.nvim_set_keymap("n", "cp", "<Cmd>:let @+=expand('%:p')<CR>", { noremap = true })
-- redo
api.nvim_set_keymap("n", "U", "<C-r>", { noremap = true })
-- remap %
api.nvim_set_keymap("n", "M", "%", { noremap = false })
-- paste with indent
api.nvim_set_keymap("n", "p", "p`]", { noremap = true })
api.nvim_set_keymap("n", "P", "P`[", { noremap = true })
-- jump to next/previous paragraph
api.nvim_set_keymap("n", "<C-j>", "}", { noremap = true })
api.nvim_set_keymap("n", "<C-k>", "{", { noremap = true })

-- ## visual mode ##
-- move cursor
api.nvim_set_keymap("x", "<S-h>", "^", { noremap = true })
api.nvim_set_keymap("x", "<S-l>", "$", { noremap = true })
-- paste without yanking
api.nvim_set_keymap("x", "p", '"_xP', { noremap = true })
-- delete without yanking
api.nvim_set_keymap("x", "x", '"_x', { noremap = true })
-- replace
vim.keymap.set("x", "<leader>R", 'y:%s/<C-r><C-r>"//g<Left><Left>')
-- text object
api.nvim_set_keymap("x", "i<space>", "iW", { noremap = true })
-- yank without moving cursor
api.nvim_set_keymap("x", "y", "mzy`z", { noremap = true })
-- indent
api.nvim_set_keymap("x", "<", "<gv", { noremap = true })
api.nvim_set_keymap("x", ">", ">gv", { noremap = true })
-- move line
-- api.nvim_set_keymap("x", "<C-j>", ":move'>+1<CR>gv=gv", { noremap = true })
-- api.nvim_set_keymap("x", "<C-k>", ":move'<-2<CR>gv=gv", { noremap = true })

-- ## terminal mode ##
api.nvim_set_keymap("t", "<esc>", [[<C-\><C-n>]], { noremap = true })
api.nvim_set_keymap("t", "jj", [[<C-\><C-n>]], { noremap = true })
api.nvim_set_keymap("t", "JJ", "<esc>", { noremap = true })
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

-- # autocmd # --
-- open quickfix
-- vim.cmd("autocmd QuickFixCmdPost *grep* cwindow")
-- vim.cmd('autocmd BufWritePost *.py ')
-- vim.cmd('autocmd!')
-- vim.cmd('autocmd!')
-- Keymap for help file
api.nvim_create_autocmd("FileType", {
    pattern = "help",
    callback = function(ev)
        local opts = { buffer = ev.buf, noremap = true, silent = true }
        -- Jump to tag
        vim.keymap.set("n", "<Leader>jt", "<C-]>", opts)
        -- Jump back
        vim.keymap.set("n", "<Leader>jb", "<C-T>", opts)
    end,
})

-- # custom commands #
-- Helper function to start AI tool based on environment variables
local function start_ai_tool()
    local use_claude_code = os.getenv("USE_CLAUDE_CODE") or "0"
    local use_cursor_cli = os.getenv("USE_CURSOR_CLI") or "0"
    if use_claude_code == "1" then
        vim.fn.chansend(vim.b.terminal_job_id, "claude\n")
    elseif use_cursor_cli == "1" then
        vim.fn.chansend(vim.b.terminal_job_id, "cursor-agent\n")
    else
        print("Both USE_CLAUDE_CODE and USE_CURSOR_CLI are not set to 1. Please set one of them.")
    end
end

-- Vst: vertical split (right) + terminal, then return to original window
api.nvim_create_user_command("Vst", function()
    local original_win = vim.fn.win_getid()
    vim.cmd("rightbelow vs")
    vim.cmd("terminal")
    vim.fn.win_gotoid(original_win)
end, {})

-- Vsc: vertical split (right) + terminal + AI tool, then return to original window
api.nvim_create_user_command("Vsc", function()
    local original_win = vim.fn.win_getid()
    vim.cmd("rightbelow vs")
    vim.cmd("terminal")
    vim.schedule(function()
        start_ai_tool()
        vim.fn.win_gotoid(original_win)
    end)
end, {})

-- Hs: horizontal split (below)
api.nvim_create_user_command("Hs", function()
    vim.cmd("rightbelow split")
end, {})

-- Hst: horizontal split (below) + terminal, then return to original window
api.nvim_create_user_command("Hst", function()
    local original_win = vim.fn.win_getid()
    vim.cmd("rightbelow split")
    vim.cmd("terminal")
    vim.fn.win_gotoid(original_win)
end, {})

-- Hsc: horizontal split (below) + terminal + AI tool, then return to original window
api.nvim_create_user_command("Hsc", function()
    local original_win = vim.fn.win_getid()
    vim.cmd("rightbelow split")
    vim.cmd("terminal")
    vim.schedule(function()
        start_ai_tool()
        vim.fn.win_gotoid(original_win)
    end)
end, {})

-- Command abbreviations for lowercase usage
vim.cmd("cnoreabbrev vst Vst")
vim.cmd("cnoreabbrev vsc Vsc")
vim.cmd("cnoreabbrev hs Hs")
vim.cmd("cnoreabbrev hst Hst")
vim.cmd("cnoreabbrev hsc Hsc")

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
