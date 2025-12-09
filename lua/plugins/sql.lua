return {
    -- Convert sql keywords to upper case
    { "jsborjesson/vim-uppercase-sql", ft = { "sql" } },
    -- Workspace
    {
        "kristijanhusak/vim-dadbod-ui",
        dependencies = {
            { "tpope/vim-dadbod", lazy = true },
            {
                "kristijanhusak/vim-dadbod-completion",
                ft = { "sql", "mysql", "plsql" },
                lazy = true,
            },
        },
        cmd = {
            "DBUI",
            "DBUIToggle",
            "DBUIAddConnection",
            "DBUIFindBuffer",
        },
        init = function()
            -- Your DBUI configuration
            vim.g.db_ui_use_nerd_fonts = 1
        end,
    },
    -- dbt model editing
    {
        "PedramNavid/dbtpal",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-telescope/telescope.nvim",
        },
        ft = {
            "sql",
            "md",
            "yaml",
        },
        keys = {
            { "<leader>drf", "<cmd>DbtRun<cr>" },
            { "<leader>drp", "<cmd>DbtRunAll<cr>" },
            { "<leader>dtf", "<cmd>DbtTest<cr>" },
            { "<leader>dm", "<cmd>lua require('dbtpal.telescope').dbt_picker()<cr>" },
        },
        config = function()
            require("dbtpal").setup({
                path_to_dbt = "dbt",
                path_to_dbt_project = "",
                path_to_dbt_profiles_dir = vim.fn.expand("~/.dbt"),
                extended_path_search = true,
                protect_compiled_files = true,
            })
            require("telescope").load_extension("dbtpal")
        end,
    },
}
