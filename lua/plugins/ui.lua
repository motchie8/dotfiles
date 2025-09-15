return {
    -- Top page for nvim
    {
        "goolord/alpha-nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            local alpha = require("alpha")
            local dashboard = require("alpha.themes.dashboard")

            -- Set header
            dashboard.section.header.val = {
                "                                                     ",
                "  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗ ",
                "  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║ ",
                "  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║ ",
                "  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║ ",
                "  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║ ",
                "  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝ ",
                "                                                     ",
            }

            -- Set menu
            dashboard.section.buttons.val = {
                dashboard.button("d", "  > Diary", ":cd $HOME/vimwiki | VimwikiMakeDiaryNote <CR>"),
                dashboard.button("c", "  > Dotfiles", ":cd $HOME/dotfiles | :e init.lua<CR>"),
                dashboard.button("r", "  > Recent files", ":Telescope oldfiles<CR>"),
                dashboard.button("f", "  > Search wiki", ":cd $HOME/vimwiki | Telescope live_grep<CR>"),
                dashboard.button("e", "  > New file", ":ene <BAR> startinsert <CR>"),
                dashboard.button("q", "󰅙  > Quit", ":qa<CR>"),
            }
            -- Send config to alpha
            alpha.setup(dashboard.opts)

            -- Disable folding on alpha buffer
            vim.cmd([[
            autocmd FileType alpha setlocal nofoldenable
        ]])
        end,
    },
    -- Outline window for navigation
    {
        "stevearc/aerial.nvim",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
            "nvim-treesitter/nvim-treesitter",
        },
        keys = {
            {
                "<leader>A",
                "<cmd>AerialToggle!<cr>",
                desc = "Toggle Aerial",
            },
        },
        config = function()
            require("aerial").setup({
                -- optionally use on_attach to set keymaps when aerial has attached to a buffer
                on_attach = function(bufnr)
                    -- Jump forwards/backwards with '{' and '}'
                    vim.keymap.set("n", "{", "<cmd>AerialPrev<CR>", { buffer = bufnr })
                    vim.keymap.set("n", "}", "<cmd>AerialNext<CR>", { buffer = bufnr })
                end,
            })
            -- set a keymap to toggle aerial
            vim.keymap.set("n", "<leader>A", "<cmd>AerialToggle!<CR>")
        end,
    },
    -- Show matched information
    {
        "kevinhwang91/nvim-hlslens",
        config = function()
            require("hlslens").setup()
            local kopts = { noremap = true, silent = true }
            vim.api.nvim_set_keymap(
                "n",
                "n",
                [[<Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>]],
                kopts
            )
            vim.api.nvim_set_keymap(
                "n",
                "N",
                [[<Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>]],
                kopts
            )
            vim.api.nvim_set_keymap("n", "*", [[*<Cmd>lua require('hlslens').start()<CR>]], kopts)
            vim.api.nvim_set_keymap("n", "#", [[#<Cmd>lua require('hlslens').start()<CR>]], kopts)
            vim.api.nvim_set_keymap("n", "g*", [[g*<Cmd>lua require('hlslens').start()<CR>]], kopts)
            vim.api.nvim_set_keymap("n", "g#", [[g#<Cmd>lua require('hlslens').start()<CR>]], kopts)

            vim.api.nvim_set_keymap("n", "<Leader>l", "<Cmd>noh<CR>", kopts)
        end,
    },
    -- Show line diff between two blocks
    {
        "AndrewRadev/linediff.vim",
        cmd = { "Linediff" },
    },
    -- colorschema
    {
        "cocopon/iceberg.vim",
        config = function()
            vim.cmd([[
		        set t_Co=256
		        colorscheme iceberg
		        filetype plugin indent on
		    ]])
        end,
    },
    -- statusline
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        opts = {
            options = { theme = "iceberg_dark" },
        },
    },
    -- resize window
    {
        "simeji/winresizer",
        keys = {
            { "<C-e>", "<cmd>WinResizerStartResize<cr>", desc = "Resize Window" },
        },
    },
    -- line decorations by vim modes
    {
        "mvllow/modes.nvim",
        tag = "v0.2.1",
        opts = {},
    },
    -- highlight word under cursor and manual keywords
    {
        "t9md/vim-quickhl",
        config = function()
            vim.cmd([[
                nmap <Space>M <Plug>(quickhl-manual-this)
                xmap <Space>M <Plug>(quickhl-manual-this)
                nmap <Space>MM <Plug>(quickhl-manual-reset)
                xmap <Space>MM <Plug>(quickhl-manual-reset)
            ]])
        end,
    },
    -- highlight indent line
    -- {
    -- 	"shellRaining/hlchunk.nvim",
    -- 	-- event = { "BufReadPre", "BufNewFile" },
    -- 	event = "VeryLazy",
    -- 	opts = {
    -- 		chunk = {
    -- 			enable = true,
    -- 			priority = 15,
    -- 			style = {
    -- 				{ fg = "#806d9c" },
    -- 				{ fg = "#c21f30" },
    -- 			},
    -- 			use_treesitter = true,
    -- 			chunk = {
    -- 				chars = {
    -- 					horizontal_line = "─",
    -- 					vertical_line = "│",
    -- 					left_top = "╭",
    -- 					left_bottom = "╰",
    -- 					right_arrow = ">",
    -- 				},
    -- 				style = "#806d9c",
    -- 			},
    -- 			textobject = "",
    -- 			max_file_size = 1024 * 1024,
    -- 			error_sign = true,
    -- 		},
    -- 		indent = {
    -- 			enable = true,
    -- 			chars = {
    -- 				"│",
    -- 				"¦",
    -- 				"┆",
    -- 				"┊",
    -- 			},
    -- 			style = {
    -- 				vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID("Whitespace")), "fg", "gui"),
    -- 			},
    -- 		},
    -- 		line_num = {
    -- 			enable = false,
    -- 		},
    -- 		blank = {
    -- 			enable = true,
    -- 			chars = {
    -- 				"․",
    -- 			},
    -- 			style = {
    -- 				{ vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID("Whitespace")), "fg", "gui"), "" },
    -- 			},
    -- 		},
    -- 	},
    -- },
    -- Display Tabs
    {
        "romgrk/barbar.nvim",
        dependencies = {
            "lewis6991/gitsigns.nvim",     -- OPTIONAL: for git status
            "nvim-tree/nvim-web-devicons", -- OPTIONAL: for file icons
        },
        init = function()
            vim.g.barbar_auto_setup = false
        end,
    },
    -- Surround selections
    {
        "kylechui/nvim-surround",
        event = "VeryLazy",
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "nvim-treesitter/nvim-treesitter-textobjects",
        },
    },
    -- Highlight todo comments
    {
        "folke/todo-comments.nvim",
        event = "VeryLazy",
        dependencies = { "nvim-lua/plenary.nvim" },
    },
    -- File Explorer
    {
        "nvim-tree/nvim-tree.lua",
        dependencies = {
            "nvim-tree/nvim-web-devicons", -- optional, for file icon
        },
        config = function()
            -- disable netrw at the very start of your init.lua
            vim.g.loaded_netrw = 1
            vim.g.loaded_netrwPlugin = 1

            -- optionally enable 24-bit colour
            vim.opt.termguicolors = true

            local function my_on_attach(bufnr)
                local api = require("nvim-tree.api")

                local function opts(desc)
                    return {
                        desc = "nvim-tree: " .. desc,
                        buffer = bufnr,
                        noremap = true,
                        silent = true,
                        nowait = true,
                    }
                end
                -- for default mappings, see :help nvim-tree-mappings-default
                -- api.config.mappings.default_on_attach(bufnr)
                -- custom mappings
                vim.keymap.set("n", "<C-r>", api.fs.rename_sub, opts("Rename: Omit Filename"))
                vim.keymap.set("n", "<C-t>", api.node.open.tab, opts("Open: New Tab"))
                vim.keymap.set("n", "<C-v>", api.node.open.vertical, opts("Open: Vertical Split"))
                vim.keymap.set("n", "<C-x>", api.node.open.horizontal, opts("Open: Horizontal Split"))
                vim.keymap.set("n", "<BS>", api.node.navigate.parent_close, opts("Close Directory"))
                vim.keymap.set("n", "<CR>", api.node.open.edit, opts("Open"))
                vim.keymap.set("n", "<Tab>", api.node.open.preview, opts("Open Preview"))
                vim.keymap.set("n", ">", api.node.navigate.sibling.next, opts("Next Sibling"))
                vim.keymap.set("n", "<", api.node.navigate.sibling.prev, opts("Previous Sibling"))
                vim.keymap.set("n", ".", api.node.run.cmd, opts("Run Command"))
                vim.keymap.set("n", "-", api.tree.change_root_to_parent, opts("Up"))
                vim.keymap.set("n", "a", api.fs.create, opts("Create File Or Directory"))
                vim.keymap.set("n", "c", api.fs.copy.node, opts("Copy"))
                vim.keymap.set("n", "d", api.fs.remove, opts("Delete"))
                vim.keymap.set("n", "D", api.fs.trash, opts("Trash"))
                vim.keymap.set("n", "E", api.tree.expand_all, opts("Expand All"))
                vim.keymap.set("n", "e", api.fs.rename_basename, opts("Rename: Basename"))
                vim.keymap.set("n", "F", api.live_filter.clear, opts("Live Filter: Clear"))
                vim.keymap.set("n", "H", api.tree.toggle_hidden_filter, opts("Toggle Filter: Dotfiles"))
                vim.keymap.set("n", "I", api.tree.toggle_gitignore_filter, opts("Toggle Filter: Git Ignore"))
                vim.keymap.set("n", "o", api.node.open.edit, opts("Open"))
                vim.keymap.set("n", "p", api.fs.paste, opts("Paste"))
                vim.keymap.set("n", "P", api.node.navigate.parent, opts("Parent Directory"))
                vim.keymap.set("n", "q", api.tree.close, opts("Close"))
                vim.keymap.set("n", "r", api.fs.rename, opts("Rename"))
                vim.keymap.set("n", "R", api.tree.reload, opts("Refresh"))
                vim.keymap.set("n", "u", api.fs.rename_full, opts("Rename: Full Path"))
                vim.keymap.set("n", "W", api.tree.collapse_all, opts("Collapse"))
                vim.keymap.set("n", "x", api.fs.cut, opts("Cut"))
                -- vim.keymap.set("n", "y", api.fs.copy.filename, opts("Copy Name"))
                vim.keymap.set("n", "y", api.fs.copy.relative_path, opts("Copy Relative Path"))
                vim.keymap.set("n", "Y", api.fs.copy.absolute_path, opts("Copy Absolute Path"))
                vim.keymap.set("n", "?", api.tree.toggle_help, opts("Help"))
            end

            require("nvim-tree").setup({
                sort = {
                    sorter = "case_sensitive",
                },
                view = {
                    centralize_selection = true,
                    width = 40,
                    number = true,
                },
                renderer = {
                    group_empty = true,
                },
                filters = {
                    dotfiles = true,
                },
                update_focused_file = {
                    enable = true,
                    update_root = {
                        enable = true,
                    },
                },
                on_attach = my_on_attach,
            })
            -- custom mappings
            vim.api.nvim_set_keymap("n", "<Leader>e", "<Cmd>NvimTreeToggle<CR>", { noremap = true })
            vim.api.nvim_set_keymap("n", "<Leader>E", "<Cmd>NvimTreeRefresh<CR>", { noremap = true })
        end,
    },
    -- Easymotion
    {
        "Lokaltog/vim-easymotion",
        keys = {
            {
                "f",
                desc = "Easymotion Overwin F",
            },
            {
                "F",
                desc = "Easymotion Overwin F2",
            },
            {
                "f",
                mode = "v",
                desc = "Easymotion BD F",
            },
            {
                "F",
                mode = "v",
                desc = "Easymotion BD F2",
            },
        },
        config = function()
            vim.api.nvim_set_var("EasyMotion_do_mapping", 0)
            vim.api.nvim_set_keymap("n", "f", "<Plug>(easymotion-overwin-f)", { noremap = false })
            vim.api.nvim_set_keymap("v", "f", "<Plug>(easymotion-bd-f)", { noremap = false })
            vim.api.nvim_set_keymap("n", "F", "<Plug>(easymotion-overwin-f2)", { noremap = false })
            vim.api.nvim_set_keymap("v", "F", "<Plug>(easymotion-bd-f2)", { noremap = false })
        end,
    },
    -- Quickfix Window
    {
        "kevinhwang91/nvim-bqf",
        ft = "qf",
        dependencies = {
            "junegunn/fzf.vim",
            "nvim-treesitter/nvim-treesitter",
        },
    },
    -- Various utilities
    {
        "folke/snacks.nvim",
        priority = 1000,
        lazy = false,
        dependencies = { "nvim-tree/nvim-web-devicons" },
        opts = {
            bigfile = { enabled = true },
            git = { enabled = true },
            gitbrowse = { enabled = true },
            image = { enabled = true },
            indent = { enabled = true },
            input = { enabled = true },
            notifier = { enabled = true },
            quickfile = { enabled = true },
            scope = { enabled = true },
            statuscolumn = { enabled = true },
            toggle = { enabled = true },
            words = { enabled = true },
        },
        keys = {
            -- Notifier
            {
                "<leader>sh",
                function()
                    Snacks.notifier.show_history()
                end,
                desc = "Notification History",
            },
            -- Picker
            {
                "sd",
                function()
                    Snacks.picker.diagnostics()
                end,
                desc = "Diagnostics",
            },
            {
                "sD",
                function()
                    Snacks.picker.diagnostics_buffer()
                end,
                desc = "Buffer Diagnostics",
            },
            {
                "sp",
                function()
                    Snacks.picker.pickers()
                end,
                desc = "Pickers",
            },
            {
                "sm",
                function()
                    Snacks.picker.keymaps()
                end,
                desc = "Keymaps",
            },
            -- {
            --     "<leader>c",
            --     function()
            --         Snacks.terminal.toggle()
            --     end,
            --     desc = "Toggle Terminal",
            -- },
        },
    },
}
