return {
    -- Vimwiki
    {
        "vimwiki/vimwiki",
        init = function()
            vim.cmd([[
                set nocompatible
                filetype plugin on
                syntax on
            ]])
            vim.api.nvim_set_var("vimwiki_list", {
                {
                    path = "~/vimwiki",
                    syntax = "markdown",
                    ext = "md",
                    auto_diary_index = 1,
                    auto_toc = 1,
                },
            })
            vim.api.nvim_set_var("vimwiki_global_ext", 1)
            vim.api.nvim_set_var("vimwiki_markdown_link_ext", 1)
            vim.api.nvim_set_var("markdown_folding", 0)

            -- register markdown files to vimwiki
            vim.api.nvim_set_var("vimwiki_filetypes", { "markdown" })
            -- disable key mappings
            vim.api.nvim_set_var("vimwiki_key_mappings", { all_maps = 0 })

            -- enable swap file only for vimwiki diary
            local function setup_swap()
                -- get the file path of the currently open buffer
                local current_file = vim.fn.expand("%:p")

                -- create a swap file if the file path is under $HOME/vimwiki/diary
                if current_file:find("/vimwiki/diary/", 1, true) then
                    vim.opt.swapfile = true
                    vim.opt.directory = ""
                else
                    -- Disable creation of swap file
                    vim.opt.swapfile = false
                end
            end
            vim.api.nvim_create_autocmd({ "BufEnter" }, {
                pattern = { "*" },
                callback = setup_swap,
            })
        end,
    },
}
