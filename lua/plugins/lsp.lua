return {
    -- Package manager for LSP, DAP, Linter, Formatter, etc.
    {
        "mason-org/mason.nvim",
        opts = {
            ui = {
                icons = {
                    package_installed = "✓",
                    package_pending = "➜",
                    package_uninstalled = "✗",
                },
                border = "single",
            },
        },
    },
    -- Make it easier to user lspconfig with mason.nvim
    {
        "mason-org/mason-lspconfig.nvim",
        dependencies = {
            "mason-org/mason.nvim",
            "neovim/nvim-lspconfig",
        },
        opts = {
            automatic_enable = true,
            ensure_installed = {
                -- [LSP] Lua
                "lua_ls", -- "lua-language-server",
                -- [LSP] Python
                "pyright",
                -- [Linter] [Formatter] [LSP] Python
                -- NOTE: Disabled due to an error: ~/.local/share/nvim/mason/packages/ruff/venv/bin/python3 not found
                -- "ruff",
                -- [LSP] [Formatter] [Linter] JSON, Javascript, Typescript, JSX, CSS, GraphQL
                "biome",
                -- [Formatter] Markdown, YAML, JSON, CSS, HTML, JSX, Javascript, Typescript
                -- "prettier",
                -- [Linter] Markdown, Text
                -- for formatting: setup none-ls.nvim: https://github.com/nvimtools/none-ls.nvim/blob/main/doc/BUILTINS.md#textlint-2
                -- "textlint",
                -- [Formatter] dbt, SQL
                -- NOTE: Disabled due to a warning: Server "sqlfluff" is not valid entry in ensure_installed.
                -- "sqlfmt",
                -- [Linter] dbt, SQL
                -- for formatting: setup none-ls.nvim: https://github.com/nvimtools/none-ls.nvim/blob/main/doc/BUILTINS.md#textlint-2
                -- NOTE: Disabled due to a warning: Server "sqlfluff" is not valid entry in ensure_installed.
                -- "sqlfluff",
                -- [LSP] [Formatter] toml
                "taplo",
                -- [Formatter] [Linter] [Runtime] terraform
                -- NOTE: Disabled due to a warning: Server "sqlfluff" is not valid entry in ensure_installed.
                -- "terraform",
                -- [LSP] terraform
                "terraformls",
                -- [LSP] bash, zsh
                "bashls",
                -- [Linter] bash
                -- NOTE: Disabled due to a warning: Server "sqlfluff" is not valid entry in ensure_installed.
                -- "shellcheck",
                -- [LSP] Docker
                "docker_compose_language_service",
            },
        },
    },
    -- LSP configuration
    {
        "neovim/nvim-lspconfig",
        dependencies = { "saghen/blink.cmp" },
        config = function()
            -- Setup
            vim.api.nvim_create_autocmd("LspAttach", {
                group = vim.api.nvim_create_augroup("UserLspConfig", {}),
                callback = function(ev)
                    -- Buffer local mappings.
                    -- See `:help vim.lsp.*` for documentation on any of the below functions
                    local opts = { buffer = ev.buf }

                    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
                    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
                    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
                    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
                    vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
                    vim.keymap.set("n", "<space>D", vim.lsp.buf.type_definition, opts)
                    vim.keymap.set("n", "<space>rn", vim.lsp.buf.rename, opts)
                    -- Use actions-preview.nvim plugin for code actions
                    -- vim.keymap.set("n", "<space>ca", vim.lsp.buf.code_action, opts)
                    vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
                    vim.keymap.set("n", "<space>fm", function()
                        vim.lsp.buf.format({ async = true })
                    end, opts)
                end,
            })
        end,
    },
    {
        "saghen/blink.cmp",
        event = { "InsertEnter", "CmdlineEnter" },
        dependencies = {
            "rafamadriz/friendly-snippets",
            "L3MON4D3/LuaSnip",
            "nvim-tree/nvim-web-devicons",
            "onsails/lspkind.nvim",
        },
        version = "1.*",
        opts = {
            -- See :h blink-cmp-config-keymap for defining your own keymap
            keymap = {
                preset = "none",
                ["<C-space>"] = { "show", "hide" },
                ["<CR>"] = { "accept", "fallback" },
                ["<Up>"] = { "select_prev", "fallback" },
                ["<Down>"] = { "select_next", "fallback" },
                ["K"] = { "show_documentation", "hide_documentation", "fallback" },
                ["<C-d>"] = { "scroll_documentation_down", "fallback" },
                ["<C-u>"] = { "scroll_documentation_up", "fallback" },
                ["<C-k>"] = { "show_signature", "hide_signature", "fallback" },
                ["<C-h>"] = { "snippet_backward", "fallback" },
                ["<C-l>"] = { "snippet_forward", "fallback" },
            },

            snippets = { preset = "luasnip" },

            appearance = {
                -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
                -- Adjusts spacing to ensure icons are aligned
                nerd_font_variant = "normal",
            },
            completion = {
                documentation = { auto_show = true, auto_show_delay_ms = 250 },
                -- Completion menu drawing: nvim-web-devicons + lspkind
                -- ref. https://cmp.saghen.dev/recipes.html#nvim-web-devicons-lspkind
                menu = {
                    draw = {
                        components = {
                            kind_icon = {
                                text = function(ctx)
                                    local icon = ctx.kind_icon
                                    if vim.tbl_contains({ "Path" }, ctx.source_name) then
                                        local dev_icon, _ = require("nvim-web-devicons").get_icon(ctx.label)
                                        if dev_icon then
                                            icon = dev_icon
                                        end
                                    else
                                        icon = require("lspkind").symbolic(ctx.kind, {
                                            mode = "symbol",
                                        })
                                    end

                                    return icon .. ctx.icon_gap
                                end,

                                -- Optionally, use the highlight groups from nvim-web-devicons
                                -- You can also add the same function for `kind.highlight` if you want to
                                -- keep the highlight groups in sync with the icons.
                                highlight = function(ctx)
                                    local hl = ctx.kind_hl
                                    if vim.tbl_contains({ "Path" }, ctx.source_name) then
                                        local dev_icon, dev_hl = require("nvim-web-devicons").get_icon(ctx.label)
                                        if dev_icon then
                                            hl = dev_hl
                                        end
                                    end
                                    return hl
                                end,
                            },
                        },
                    },
                },
            },
            sources = {
                -- Snippets as the first source
                default = { "snippets", "lsp", "path", "buffer" },
                providers = {
                    lsp = {
                        name = "LSP",
                        module = "blink.cmp.sources.lsp",
                        enabled = true,
                        transform_items = function(_, items)
                            -- Filter out text items from LSP to reduce noise
                            return vim.tbl_filter(function(item)
                                return item.kind ~= require("blink.cmp.types").CompletionItemKind.Text
                            end, items)
                        end,
                    },
                    buffer = {
                        opts = {
                            get_bufnrs = function()
                                return vim.tbl_filter(function(bufnr)
                                    return vim.bo[bufnr].buftype == ""
                                end, vim.api.nvim_list_bufs())
                            end,
                        },
                    },
                },
            },
            -- Terminal completions may not be stable yet
            term = {
                enabled = true,
            },
            -- (Default) Rust fuzzy matcher for typo resistance and significantly better performance
            fuzzy = { implementation = "prefer_rust_with_warning" },
        },
        opts_extend = { "sources.default" },
    },
    -- Provide a way for non-LSP sources to hook into Neovim's LSP client
    {
        "nvimtools/none-ls.nvim",
        event = "VeryLazy",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            local null_ls = require("null-ls")
            null_ls.setup({
                sources = {
                    null_ls.builtins.formatting.sqlfluff.with({
                        extra_args = { "--dialect", "bigquery" },
                        filetypes = { "sql", "dbt" },
                    }),
                    null_ls.builtins.diagnostics.sqlfluff.with({
                        extra_args = { "--dialect", "bigquery" },
                        filetypes = { "sql", "dbt" },
                    }),
                },
            })
        end,
    },
    -- Auto formatting on save
    {
        "lukas-reineke/lsp-format.nvim",
        config = function()
            require("lsp-format").setup()

            vim.api.nvim_create_autocmd("LspAttach", {
                group = vim.api.nvim_create_augroup("LspFormat", {}),
                desc = "Enable LSP formatting on LspAttach",
                pattern = "*",
                -- This will run after the LSP client is attached to the buffer
                -- and will set up the formatter for that client.
                callback = function(args)
                    local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
                    require("lsp-format").on_attach(client, args.buf)
                end,
            })
            -- Format on save synchronously
            vim.cmd [[cabbrev wq execute "Format sync" <bar> wq]]
        end,
    },
    -- vscode-like pictograms for lsp completion items
    {
        "onsails/lspkind.nvim",
        event = "VeryLazy",
    },
    -- Snippet
    {
        "L3MON4D3/LuaSnip",
        -- follow latest release.
        version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
        -- install jsregexp (optional!).
        build = "make install_jsregexp",
        config = function()
            require("luasnip.loaders.from_lua").load({ paths = { "~/dotfiles/snippets/luasnip" } })
        end,
    },
    -- Previw code with code actions applied
    {
        "aznhe21/actions-preview.nvim",
        event = "VeryLazy",
        opts = {
            telescope = {
                sorting_strategy = "ascending",
                layout_strategy = "vertical",
                layout_config = {
                    width = 0.8,
                    height = 0.9,
                    prompt_position = "top",
                    preview_cutoff = 20,
                    preview_height = function(_, _, max_lines)
                        return max_lines - 15
                    end,
                },
            },
        },
        config = function()
            vim.keymap.set("n", "<leader>ca", require("actions-preview").code_actions)
        end,
    },
    -- Inline diagnostics
    {
        "rachartier/tiny-inline-diagnostic.nvim",
        event = "LspAttach",
        priority = 1000, -- needs to be loaded in first
        config = function()
            require("tiny-inline-diagnostic").setup()
            vim.diagnostic.config({ virtual_text = false }) -- Only if needed in your configuration, if you already have native LSP diagnostics
        end,
    },
    --- Currently disabled ---
    {
        "ray-x/lsp_signature.nvim",
        enabled = false,
        event = "VeryLazy",
        config = function()
            require("lsp_signature").setup({})
        end,
    },
    {
        "j-hui/fidget.nvim",
        enabled = false,
        event = "VeryLazy",
        tag = "legacy",
        config = function()
            require("fidget").setup({})
        end,
    },
    {
        "folke/trouble.nvim",
        enabled = false,
        event = "VeryLazy",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        cmd = { "TroubleToggle", "Trouble" },
        config = function()
            require("trouble").setup({})
        end,
    },
    {
        "neoclide/coc.nvim",
        enabled = false,
        branch = "release",
        config = function()
            -- https://raw.githubusercontent.com/neoclide/coc.nvim/master/doc/coc-example-config.lua
            -- Some servers have issues with backup files, see #649
            vim.opt.backup = false
            vim.opt.writebackup = false

            -- Having longer updatetime (default is 4000 ms = 4s) leads to noticeable
            -- delays and poor user experience
            vim.opt.updatetime = 50

            -- Always show the signcolumn, otherwise it would shift the text each time
            -- diagnostics appeared/became resolved
            vim.opt.signcolumn = "yes"

            local keyset = vim.keymap.set
            -- Autocomplete
            function _G.check_back_space()
                local col = vim.fn.col(".") - 1
                return col == 0 or vim.fn.getline("."):sub(col, col):match("%s") ~= nil
            end

            -- Use Tab for trigger completion with characters ahead and navigate
            -- NOTE: There's always a completion item selected by default, you may want to enable
            -- no select by setting `"suggest.noselect": true` in your configuration file
            -- NOTE: Use command ':verbose imap <tab>' to make sure Tab is not mapped by
            -- other plugins before putting this into your config
            local opts = { silent = true, noremap = true, expr = true, replace_keycodes = false }
            -- HACK: Disable Tab Key for Copilot
            -- keyset("i", "<TAB>", 'coc#pum#visible() ? coc#pum#next(1) : v:lua.check_back_space() ? "<TAB>" : coc#refresh()', opts)
            -- keyset("i", "<S-TAB>", [[coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"]], opts)

            -- Make <CR> to accept selected completion item or notify coc.nvim to format
            -- <C-g>u breaks current undo, please make your own choice
            keyset(
                "i",
                "<cr>",
                [[coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"]],
                opts
            )

            -- Use <c-j> to trigger snippets
            keyset("i", "<c-j>", "<Plug>(coc-snippets-expand-jump)")
            -- Use <c-space> to trigger completion
            keyset("i", "<c-space>", "coc#refresh()", { silent = true, expr = true })

            -- Use `[g` and `]g` to navigate diagnostics
            -- Use `:CocDiagnostics` to get all diagnostics of current buffer in location list
            keyset("n", "[g", "<Plug>(coc-diagnostic-prev)", { silent = true })
            keyset("n", "]g", "<Plug>(coc-diagnostic-next)", { silent = true })

            -- GoTo code navigation
            keyset("n", "gd", "<Plug>(coc-definition)", { silent = true })
            keyset("n", "gy", "<Plug>(coc-type-definition)", { silent = true })
            keyset("n", "gi", "<Plug>(coc-implementation)", { silent = true })
            keyset("n", "gr", "<Plug>(coc-references)", { silent = true })

            -- Use K or Ctrl-h to show documentation in preview window
            function _G.show_docs()
                local cw = vim.fn.expand("<cword>")
                if vim.fn.index({ "vim", "help" }, vim.bo.filetype) >= 0 then
                    vim.api.nvim_command("h " .. cw)
                elseif vim.api.nvim_eval("coc#rpc#ready()") then
                    vim.fn.CocActionAsync("doHover")
                else
                    vim.api.nvim_command("!" .. vim.o.keywordprg .. " " .. cw)
                end
            end

            keyset("n", "K", "<CMD>lua _G.show_docs()<CR>", { silent = true })
            keyset("n", "<C-h>", "<CMD>lua _G.show_docs()<CR>", { silent = true })

            -- Highlight the symbol and its references on a CursorHold event(cursor is idle)
            vim.api.nvim_create_augroup("CocGroup", {})
            vim.api.nvim_create_autocmd("CursorHold", {
                group = "CocGroup",
                command = "silent call CocActionAsync('highlight')",
                desc = "Highlight symbol under cursor on CursorHold",
            })

            -- Symbol renaming
            keyset("n", "<leader>rn", "<Plug>(coc-rename)", { silent = true })

            -- Setup formatexpr specified filetype(s)
            vim.api.nvim_create_autocmd("FileType", {
                group = "CocGroup",
                pattern = "typescript,json",
                command = "setl formatexpr=CocAction('formatSelected')",
                desc = "Setup formatexpr specified filetype(s).",
            })

            -- Update signature help on jump placeholder
            vim.api.nvim_create_autocmd("User", {
                group = "CocGroup",
                pattern = "CocJumpPlaceholder",
                command = "call CocActionAsync('showSignatureHelp')",
                desc = "Update signature help on jump placeholder",
            })

            -- Remap <C-f> and <C-b> to scroll float windows/popups
            ---@diagnostic disable-next-line: redefined-local
            local opts = { silent = true, nowait = true, expr = true }
            keyset("n", "<C-f>", 'coc#float#has_scroll() ? coc#float#scroll(1) : "<C-f>"', opts)
            keyset("n", "<C-b>", 'coc#float#has_scroll() ? coc#float#scroll(0) : "<C-b>"', opts)
            keyset("i", "<C-f>", 'coc#float#has_scroll() ? "<c-r>=coc#float#scroll(1)<cr>" : "<Right>"', opts)
            keyset("i", "<C-b>", 'coc#float#has_scroll() ? "<c-r>=coc#float#scroll(0)<cr>" : "<Left>"', opts)
            keyset("v", "<C-f>", 'coc#float#has_scroll() ? coc#float#scroll(1) : "<C-f>"', opts)
            keyset("v", "<C-b>", 'coc#float#has_scroll() ? coc#float#scroll(0) : "<C-b>"', opts)

            -- Add `:Format` command to format current buffer
            vim.api.nvim_create_user_command("Format", "call CocAction('format')", {})

            -- " Add `:Fold` command to fold current buffer
            vim.api.nvim_create_user_command("Fold", "call CocAction('fold', <f-args>)", { nargs = "?" })

            -- Add (Neo)Vim's native statusline support
            -- NOTE: Please see `:h coc-status` for integrations with external plugins that
            -- provide custom statusline: lightline.vim, vim-airline
            vim.opt.statusline:prepend("%{coc#status()}%{get(b:,'coc_current_function','')}")

            vim.api.nvim_set_var("coc_global_extensions", {
                "coc-cfn-lint",
                "coc-docker",
                "coc-eslint",
                "coc-highlight",
                "coc-jedi",
                "coc-json",
                "coc-lists",
                "coc-lua",
                "coc-prettier",
                "coc-pyright",
                "coc-rls",
                "coc-rust-analyzer",
                "coc-sh",
                -- "coc-snippets",
                --"coc-sql",
                "coc-sqlfluff",
                "coc-toml",
                "coc-tsserver",
                "coc-xml",
                "coc-yaml",
                "@yaegassy/coc-pysen",
                --"@yaegassy/coc-ruff",
            })

            vim.api.nvim_create_user_command("EnableCocFormat", function()
                local id = vim.api.nvim_create_augroup("cocfmt", {})
                vim.api.nvim_create_autocmd({ "BufWritePre" }, {
                    pattern = { "*" },
                    command = "CocCommand prettier.forceFormatDocument",
                    group = id,
                })
            end, {})
            vim.api.nvim_create_user_command("DisableCocFormat", function()
                vim.api.nvim_del_augroup_by_name("cocfmt")
            end, {})
        end,
    },
    -- Preview results from coc.nvim
    {
        "fannheyward/telescope-coc.nvim",
        enabled = false,
        dependencies = { "neoclide/coc.nvim", "nvim-telescope/telescope.nvim" },
        event = "VeryLazy",
        config = function()
            require("telescope").setup({
                extensions = {
                    coc = {
                        theme = "ivy",
                        prefer_locations = true, -- always use Telescope locations to preview definitions/declarations/implementations etc
                    },
                },
            })
            require("telescope").load_extension("coc")
            vim.api.nvim_set_keymap("n", "gd", "<Cmd>Telescope coc definitions<CR>", { noremap = true })
            -- vim.api.nvim_set_keymap("n", "gp", "<Cmd>Telescope coc type_definitions<CR>", { noremap = true })
            vim.api.nvim_set_keymap("n", "gi", "<Cmd>Telescope coc implementations<CR>", { noremap = true })
            vim.api.nvim_set_keymap("n", "gr", "<Cmd>Telescope coc references<CR>", { noremap = true })
            vim.api.nvim_set_keymap("n", "ge", "<Cmd>Telescope coc diagnostics<CR>", { noremap = true })
        end,
    },
}
