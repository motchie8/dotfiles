return {
    -- Toggle Terminal
    {
        "akinsho/toggleterm.nvim",
        event = "VeryLazy",
        version = "*",
        config = function()
            require("toggleterm").setup({
                size = 20,
                shade_terminals = false,
            })
            vim.api.nvim_set_keymap("n", "<Leader>t", "<Cmd>ToggleTerm<CR>", { noremap = true, silent = true })
            vim.api.nvim_set_keymap("n", "<Leader>tt", "<Cmd>2ToggleTerm<CR>", { noremap = true, silent = true })
            vim.api.nvim_set_keymap(
                "n",
                -- float
                "<Leader>tf",
                "<Cmd>ToggleTerm direction=float<CR>",
                { noremap = true, silent = true }
            )
            vim.api.nvim_set_keymap(
                "n",
                -- horizontal
                "<Leader>th",
                "<Cmd>ToggleTerm direction=horizontal<CR>",
                { noremap = true, silent = true }
            )
            vim.api.nvim_set_keymap(
                "n",
                -- vertical
                "<Leader>tv",
                "<Cmd>ToggleTerm direction=vertical size=70<CR>",
                { noremap = true, silent = true }
            )
        end,
    },
}
