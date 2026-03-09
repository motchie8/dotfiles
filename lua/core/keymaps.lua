local api = vim.api

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
