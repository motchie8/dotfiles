return {
    -- Render Markdown View
    {
        "MeanderingProgrammer/render-markdown.nvim",
        dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
        ft = {
            "markdown",
            "vimwiki.markdown",
            "md",
        },
        file_types = {
            "markdown",
            "vimwiki.markdown",
            "md",
        },
        keys = {
            {
                "<leader>rm",
                "<cmd>RenderMarkdown toggle<cr>",
                desc = "Toggle Render Markdown View",
            },
        },
        opts = {
            enabled = false,
        },
    },
    {
        "Kicamon/markdown-table-mode.nvim",
        config = function()
            require("markdown-table-mode").setup()
            vim.keymap.set(
                "n",
                "<leader>mt",
                "<cmd>Mtm<cr>",
                { desc = "Toggle Markdown Table Mode" }
            )
        end,
    },
}
