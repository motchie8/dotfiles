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
                -- [LSP] [Formatter] toml
                "taplo",
                -- [LSP] terraform
                "terraformls",
                -- [LSP] bash, zsh
                "bashls",
                -- [LSP] Docker
                "docker_compose_language_service",
                -- [LSP] helm charts
                "helm_ls",
                -- [LSP] Vim script
                "vimls",
                -- [LSP] yaml
                "yamlls",
            },
        },
    },
    -- LSP configuration
    {
        "neovim/nvim-lspconfig",
        dependencies = { "saghen/blink.cmp" },
        config = function()
            vim.keymap.set('n', 'gh', "<cmd>lua vim.lsp.buf.hover()<CR>", { desc = "LSP Hover" })
            vim.keymap.set('n', 'K', "<cmd>lua vim.lsp.buf.hover()<CR>", { desc = "LSP Hover" })
            vim.keymap.set('n', 'gf', "<cmd>lua vim.lsp.buf.formatting()<CR>", { desc = "LSP Format" })
            vim.keymap.set('n', 'gr', "<cmd>lua vim.lsp.buf.references()<CR>", { desc = "LSP References" })
            vim.keymap.set('n', 'gd', "<cmd>lua vim.lsp.buf.definition()<CR>", { desc = "LSP Definition" })
            vim.keymap.set('n', 'gD', "<cmd>lua vim.lsp.buf.declaration()<CR>", { desc = "LSP Declaration" })
            vim.keymap.set('n', 'gi', "<cmd>lua vim.lsp.buf.implementation()<CR>", { desc = "LSP Implementation" })
            vim.keymap.set('n', 'gy', "<cmd>lua vim.lsp.buf.type_definition()<CR>", { desc = "LSP Type Definition" })
            vim.keymap.set("n", "<space>D", "<cmd>lua vim.lsp.buf.type_definition()<CR>",
                { desc = "LSP Type Definition" })
            vim.keymap.set('n', 'gn', "<cmd>lua vim.lsp.buf.rename()<CR>", { desc = "LSP Rename" })
            vim.keymap.set("n", "<space>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", { desc = "LSP Rename" })
            vim.keymap.set('n', 'ga', "<cmd>lua vim.lsp.buf.code_action()<CR>", { desc = "LSP Code Action" })
            vim.keymap.set("n", 'gs', "<cmd>lua vim.lsp.buf.signature_help()<CR>", { desc = "LSP Signature Help" })
            vim.keymap.set("n", "<C-s>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", { desc = "LSP Signature Help" })
            vim.keymap.set('n', 'ge', "<cmd>lua vim.diagnostic.open_float()<CR>", { desc = "LSP Show Line Diagnostics" })
            vim.keymap.set('n', 'g]', "<cmd>lua vim.diagnostic.goto_next()<CR>", { desc = "LSP Next Diagnostic" })
            vim.keymap.set('n', 'g[', "<cmd>lua vim.diagnostic.goto_prev()<CR>", { desc = "LSP Previous Diagnostic" })
            vim.keymap.set("n", 'gf', "<cmd>lua vim.lsp.buf.format({ async = false })<CR>", { desc = "LSP Format" })
            vim.keymap.set("n", "<space>fm", "<cmd>lua vim.lsp.buf.format({ async = false })<CR>",
                { desc = "LSP Format" })
            -- set python path for pyright if a .venv folder is present in the project root
            if vim.fn.filereadable(vim.fn.getcwd() .. "/.venv/bin/python") == 1 then
                require("lspconfig").pyright.setup({
                    settings = {
                        python = {
                            pythonPath = vim.fn.getcwd() .. "/.venv/bin/python",
                        },
                    },
                })
            end
        end
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
                        extra_args = { "--dialect", "bigquery", "--templater", "jinja" },
                        filetypes = { "sql", "dbt" },
                    }),
                    null_ls.builtins.diagnostics.sqlfluff.with({
                        extra_args = { "--dialect", "bigquery", "--templater", "jinja" },
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
    }
}
