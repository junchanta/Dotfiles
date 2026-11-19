return {
    -- indent guides for Neovim
    {
        "lukas-reineke/indent-blankline.nvim",
        event = "VeryLazy",
        opts = {
            indent = {
                char = "│",
                tab_char = "│",
            },
            scope = { enabled = false },
            exclude = {
                filetypes = {
                    "help",
                    "alpha",
                    "dashboard",
                    "neo-tree",
                    "Trouble",
                    "trouble",
                    "lazy",
                    "mason",
                    "notify",
                    "toggleterm",
                    "lazyterm",
                },
            },
        },
        main = "ibl",
    },
    -- Active indent guide and indent text objects
    {
        "echasnovski/mini.indentscope",
        version = false,
        event = "VeryLazy",
        opts = {
            symbol = "│",
            options = { try_as_border = true },
        },
        init = function()
            vim.api.nvim_create_autocmd("FileType", {
                pattern = {
                    "help",
                    "alpha",
                    "dashboard",
                    "neo-tree",
                    "Trouble",
                    "trouble",
                    "lazy",
                    "mason",
                    "notify",
                    "toggleterm",
                    "lazyterm",
                },
                callback = function()
                    vim.b.miniindentscope_disable = true
                end,
            })
        end,
    },
    -- Displays a popup with possible key bindings
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        init = function()
            vim.o.timeout = true
            vim.o.timeoutlen = 500
        end,
        opts = {},
    },
    -- ui components
    { "MunifTanjim/nui.nvim", lazy = true },
    -- lualine
    {
        "nvim-lualine/lualine.nvim",
        lazy = false, -- ステータスラインは即座にロードする必要がある
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            -- カスタムテーマ（境界を見やすく）
            local colors = {
                bg = "#1a1b26",
                fg = "#c0caf5",
                blue = "#7aa2f7",
                cyan = "#7dcfff",
                gray = "#565f89",
                -- 非アクティブ用（明るめ）
                inactive_bg = "#292e42",
                inactive_fg = "#a9b1d6",
            }

            local custom_theme = {
                normal = {
                    a = { bg = colors.blue, fg = colors.bg, gui = "bold" },
                    b = { bg = "#3b4261", fg = colors.fg },
                    c = { bg = colors.bg, fg = colors.fg },
                },
                insert = {
                    a = { bg = colors.cyan, fg = colors.bg, gui = "bold" },
                },
                visual = {
                    a = { bg = "#bb9af7", fg = colors.bg, gui = "bold" },
                },
                replace = {
                    a = { bg = "#f7768e", fg = colors.bg, gui = "bold" },
                },
                inactive = {
                    a = { bg = colors.inactive_bg, fg = colors.inactive_fg },
                    b = { bg = colors.inactive_bg, fg = colors.inactive_fg },
                    c = { bg = colors.inactive_bg, fg = colors.gray },
                },
            }

            require("lualine").setup({
                options = {
                    theme = custom_theme,
                    globalstatus = true, -- VSCodeのように画面最下部に1つのステータスバー
                    component_separators = { left = "│", right = "│" },
                    section_separators = { left = "", right = "" },  -- Powerline風セパレータ
                },
                sections = {
                    lualine_a = { "mode" },
                    lualine_b = { "branch", "diff", "diagnostics" },
                    lualine_c = {},
                    lualine_x = { "filetype" },
                    lualine_y = { "progress" },
                    lualine_z = { "location" },
                },
                -- 各ウィンドウにファイル名を表示（winbar）
                winbar = {
                    lualine_c = {
                        {
                            "filename",
                            path = 1,
                            file_status = true,
                            newfile_status = true,
                            symbols = { modified = " ●", readonly = " ", unnamed = "[No Name]" },
                            color = { bg = "#1f2335", fg = "#7aa2f7", gui = "bold" },
                        },
                    },
                },
                inactive_winbar = {
                    lualine_c = {
                        {
                            "filename",
                            path = 1,
                            file_status = true,
                            symbols = { modified = " ●", readonly = " ", unnamed = "[No Name]" },
                            color = { bg = "#16161e", fg = "#565f89" },
                        },
                    },
                },
            })
        end,
    },
    -- aerial.nvim - コードアウトライン（symbols-outline.nvim の後継）
    -- 使い方:
    --   <leader>cs : アウトライン表示トグル
    --   { / }      : 前/次のシンボルにジャンプ
    --   <C-j/k>    : アウトライン内で移動してジャンプ
    {
        "stevearc/aerial.nvim",
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "nvim-tree/nvim-web-devicons",
        },
        keys = {
            { "<leader>co", "<cmd>AerialToggle!<cr>", desc = "Aerial (Symbols Outline)" },
            { "{", "<cmd>AerialPrev<cr>", desc = "Previous symbol" },
            { "}", "<cmd>AerialNext<cr>", desc = "Next symbol" },
        },
        opts = {
            -- アウトラインの表示位置
            layout = {
                default_direction = "right",
                min_width = 30,
            },
            -- アタッチするバックエンド（LSP + Treesitter）
            backends = { "lsp", "treesitter", "markdown", "man" },
            -- フィルタするシンボル（不要なものを除外）
            filter_kind = {
                "Class",
                "Constructor",
                "Enum",
                "Function",
                "Interface",
                "Method",
                "Module",
                "Struct",
            },
            -- ハイライト
            highlight_on_hover = true,
            -- 自動的にカーソル位置のシンボルを選択
            autojump = false,
            -- アウトラインを開いた時にフォーカスしない
            close_on_select = false,
        },
    },
}
