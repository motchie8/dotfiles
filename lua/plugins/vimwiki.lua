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
            vim.api.nvim_set_var("taskwiki_markup_syntax", "markdown")
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
    -- task management
    {
        "tools-life/taskwiki",
        dependencies = {
            "vimwiki/vimwiki",
            -- color support in charts
            "powerman/vim-plugin-AnsiEsc",
            -- taskwiki file navigation
            "preservim/tagbar",
            -- grid view
            "blindFS/vim-taskwarrior",
        },
        config = function()
            vim.api.nvim_set_keymap(
                "n",
                "td",
                "<Cmd>TaskWikiDone<CR>",
                { noremap = true, silent = true }
            )
            vim.api.nvim_set_keymap(
                "n",
                "tdd",
                "<Cmd>TaskWikiDelete<CR>",
                { noremap = true, silent = true }
            )
            vim.api.nvim_set_keymap(
                "n",
                "tt",
                "<Cmd>TaskWikiToggle<CR>",
                { noremap = true, silent = true }
            )
            vim.api.nvim_set_keymap(
                "n",
                "te",
                "<Cmd>TaskWikiEdit<CR>",
                { noremap = true, silent = true }
            )
            vim.api.nvim_set_keymap(
                "n",
                "tm",
                "<Cmd>TaskWikiMod<CR>",
                { noremap = true, silent = true }
            )
            -- Custom keymaps
            -- Clear taskwiki lines
            vim.api.nvim_set_keymap(
                "n",
                "tc",
                "<Cmd>%s/\\v^ *\\* \\[.\\] .* !{1,3} *\\(\\d{4}-\\d{2}-\\d{2}\\) *#\\w{8} *\\n//g<CR>",
                { noremap = true, silent = true }
            )
            -- Convert taskwiki lines to markdown list
            vim.api.nvim_set_keymap(
                "n",
                "tl",
                "<Cmd>%s/\\v^ *\\* \\[.\\]( ---) (.*) !{1,3} *\\(\\d{4}-\\d{2}-\\d{2}\\)? *#\\w{8} *\\n//g<CR><BAR><Cmd>%s/\\v^ *\\* \\[.\\] (.*) !{1,3} *\\(\\d{4}-\\d{2}-\\d{2}\\) *#\\w{8} */- \\[ \\] \\1/g<CR>",
                { noremap = true, silent = true }
            )
        end,
    },
}
