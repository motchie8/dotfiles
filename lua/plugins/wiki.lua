return {
    -- Vimwiki
    -- {
    --     "vimwiki/vimwiki",
    --     cmd = "VimwikiMakeDiaryNote",
    --     init = function()
    --         vim.cmd([[
    --             set nocompatible
    --             filetype plugin on
    --             syntax on
    --         ]])
    --         vim.api.nvim_set_var("vimwiki_list", {
    --             {
    --                 path = "~/vimwiki",
    --                 syntax = "markdown",
    --                 ext = "md",
    --                 auto_diary_index = 1,
    --                 auto_toc = 1,
    --             },
    --         })
    --         vim.api.nvim_set_var("vimwiki_global_ext", 1)
    --         vim.api.nvim_set_var("vimwiki_markdown_link_ext", 1)
    --         vim.api.nvim_set_var("markdown_folding", 0)

    --         -- register markdown files to vimwiki
    --         vim.api.nvim_set_var("vimwiki_filetypes", { "markdown" })
    --         -- disable key mappings
    --         vim.api.nvim_set_var("vimwiki_key_mappings", { all_maps = 0 })

    --         -- enable swap file only for vimwiki diary
    --         local function setup_swap()
    --             -- get the file path of the currently open buffer
    --             local current_file = vim.fn.expand("%:p")

    --             -- create a swap file if the file path is under $HOME/vimwiki/diary
    --             if current_file:find("/vimwiki/diary/", 1, true) then
    --                 vim.opt.swapfile = true
    --                 vim.opt.directory = ""
    --             else
    --                 -- Disable creation of swap file
    --                 vim.opt.swapfile = false
    --             end
    --         end
    --         vim.api.nvim_create_autocmd({ "BufEnter" }, {
    --             pattern = { "*" },
    --             callback = setup_swap,
    --         })
    --     end,
    -- },
    -- obsidian
    {
        "obsidian-nvim/obsidian.nvim",
        version = "*", -- recommended, use latest release instead of latest commit
        -- ft = "markdown",
        cmd = { "Obsidian", "ObsidianFleeting", "ObsidianLiterature", "ObsidianPermanent" },
        keys = {
            { "<leader>of", "<cmd>ObsidianFleeting<CR>", desc = "New Fleeting Note" },
            { "<leader>ol", "<cmd>ObsidianLiterature<CR>", desc = "New Literature Note" },
            { "<leader>op", "<cmd>ObsidianPermanent<CR>", desc = "New Permanent Note" },
        },
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-telescope/telescope.nvim",
            "nvim-treesitter/nvim-treesitter",
        },
        config = function()
            require("obsidian").setup({
                legacy_commands = false,
                workspaces = {
                    {
                        name = "vault",
                        path = "~/vaults/vault",
                    },
                },
                preferred_link_stype = "markdown",
                -- notes_subdir = "notes",
                daily_notes = {
                    folder = "00-dailies",
                    default_tags = { "daily" },
                    template = "daily.md",
                },
                templates = {
                    folder = "templates",
                },
                ui = {
                    ignore_conceal_warn = true,
                },
            })

            -- ヘルパー関数
            local function create_zettel(folder, template_name)
                local vault_path = vim.fn.expand("~/vaults/vault")
                local timestamp = os.date("%Y-%m-%dT%H:%M:%S")
                local today = os.date("%Y-%m-%d")

                local note_filename = timestamp .. ".md"
                local note_dir = vault_path .. "/" .. folder
                local note_path = note_dir .. "/" .. note_filename
                local daily_path = vault_path .. "/00-dailies/" .. today .. ".md"
                local tmpl_path = vault_path .. "/templates/" .. template_name

                -- ディレクトリを作成（なければ）
                vim.fn.mkdir(note_dir, "p")

                -- テンプレート読み込みと変数展開
                local lines = {}
                local tf = io.open(tmpl_path, "r")
                if tf then
                    for line in tf:lines() do
                        line = line:gsub("{{date}}", today)
                        line = line:gsub("{{time}}", os.date("%H:%M:%S"))
                        line = line:gsub("{{title}}", timestamp)
                        table.insert(lines, line)
                    end
                    tf:close()
                end

                -- ノートファイルを書き込み
                local nf = io.open(note_path, "w")
                if nf then
                    nf:write(table.concat(lines, "\n"))
                    if #lines > 0 then
                        nf:write("\n")
                    end
                    nf:close()
                end

                -- デイリーノートの末尾にリンクを追記
                local rel = folder .. "/" .. note_filename
                local link = "- [" .. rel .. "](../" .. rel .. ")"
                local df = io.open(daily_path, "a")
                if df then
                    df:write(link .. "\n")
                    df:close()
                end

                -- 右側に vsplit で開く
                vim.cmd("rightbelow vsplit " .. vim.fn.fnameescape(note_path))
            end

            -- カスタムコマンド登録
            vim.api.nvim_create_user_command("ObsidianFleeting", function()
                create_zettel("01-fleeting-notes", "fleeting-note.md")
            end, {})

            vim.api.nvim_create_user_command("ObsidianLiterature", function()
                create_zettel("02-literature-notes", "literature-note.md")
            end, {})

            vim.api.nvim_create_user_command("ObsidianPermanent", function()
                create_zettel("03-permanent-notes", "permanent-note.md")
            end, {})
        end,
    },
}
