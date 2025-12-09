return {
    -- Render Markdown View
    {
        "MeanderingProgrammer/render-markdown.nvim",
        dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
        ft = {
            "markdown",
            "vimwiki.markdown",
        },
        keys = {
            {
                "<leader>rm",
                "<cmd>RenderMarkdown toggle<cr>",
                desc = "Toggle Render Markdown View",
            },
        },
        opts = {},
    },
}
