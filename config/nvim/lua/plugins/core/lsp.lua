return {
    -- fidget: LSPの進捗状況を右下に表示
    {
        "j-hui/fidget.nvim",
        event = "LspAttach",
        opts = {
            notification = {
                window = {
                    winblend = 0,  -- 透明度（0=不透明）
                },
            },
        },
    },
    -- lspsaga: LSP UI の強化
    -- 使い方:
    --   K          : ホバー（ドキュメント表示）
    --   gd         : 定義へジャンプ（プレビュー付き）
    --   gD         : 定義をプレビュー（ジャンプしない）
    --   gr         : 参照一覧
    --   gi         : 実装へジャンプ
    --   <space>rn  : リネーム
    --   <space>ca  : コードアクション
    --   [d / ]d    : 前/次の診断へジャンプ
    --   <space>e   : 診断をフロート表示
    --   <space>o   : アウトライン表示
    {
        "nvimdev/lspsaga.nvim",
        event = "LspAttach",
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "nvim-tree/nvim-web-devicons",
        },
        config = function()
            require("lspsaga").setup({
                ui = {
                    border = "rounded",
                    title = true,
                },
                hover = {
                    max_width = 0.6,
                    max_height = 0.6,
                },
                lightbulb = {
                    enable = false,
                },
                symbol_in_winbar = {
                    enable = false,
                },
                outline = {
                    layout = "float",
                },
            })

            -- キーマップを直接設定
            local keymap = vim.keymap.set
            local opts = { noremap = true, silent = true }
            keymap("n", "K", "<cmd>Lspsaga hover_doc<cr>", opts)
            keymap("n", "gd", "<cmd>Lspsaga goto_definition<cr>", opts)
            keymap("n", "gD", "<cmd>Lspsaga peek_definition<cr>", opts)
            keymap("n", "gr", "<cmd>Lspsaga finder<cr>", opts)
            keymap("n", "gi", "<cmd>Lspsaga finder imp<cr>", opts)
            keymap("n", "<space>rn", "<cmd>Lspsaga rename<cr>", opts)
            keymap({ "n", "v" }, "<space>ca", "<cmd>Lspsaga code_action<cr>", opts)
            keymap("n", "[d", "<cmd>Lspsaga diagnostic_jump_prev<cr>", opts)
            keymap("n", "]d", "<cmd>Lspsaga diagnostic_jump_next<cr>", opts)
            keymap("n", "<space>e", "<cmd>Lspsaga show_line_diagnostics<cr>", opts)
            keymap("n", "<space>o", "<cmd>Lspsaga outline<cr>", opts)
        end,
    },
    -- lsp
    {
        "neovim/nvim-lspconfig",
        cmd = { "LspInfo", "LspLog" },
        event = { "BufRead" },
        dependencies = {
            { "folke/lazydev.nvim", opts = {} },
            "mason.nvim",
            "williamboman/mason-lspconfig.nvim",
        },
        opts = {
            servers = {
                lua_ls = {
                    settings = {
                        Lua = {
                            workspace = {
                                checkThirdParty = false,
                            },
                            completion = {
                                callSnippet = "Replace",
                            },
                        },
                    },
                },
                gopls = {
                    settings = {
                        gopls = {
                            gofumpt = true,
                            codelenses = {
                                gc_details = false,
                                generate = true,
                                regenerate_cgo = true,
                                run_govulncheck = true,
                                test = true,
                                tidy = true,
                                upgrade_dependency = true,
                                vendor = true,
                            },
                            hints = {
                                assignVariableTypes = true,
                                compositeLiteralFields = true,
                                compositeLiteralTypes = true,
                                constantValues = true,
                                functionTypeParameters = true,
                                parameterNames = true,
                                rangeVariableTypes = true,
                            },
                            analyses = {
                                fieldalignment = true,
                                nilness = true,
                                unusedparams = true,
                                unusedwrite = true,
                                useany = true,
                            },
                            usePlaceholders = true,
                            completeUnimported = true,
                            staticcheck = true,
                            directoryFilters = { "-.git", "-.vscode", "-.idea", "-.vscode-test", "-node_modules" },
                            semanticTokens = true,
                        },
                    },
                },
            },
        },
        config = function(_, opts)
            -- Diagnostic の設定（lspsaga が UI を担当するが、基本設定は残す）
            vim.diagnostic.config({
                float = {
                    border = "rounded",
                    source = "always",
                    header = "",
                    prefix = "",
                },
                virtual_text = {
                    spacing = 4,
                    source = "if_many",
                    prefix = "●",
                },
                signs = {
                    text = {
                        [vim.diagnostic.severity.ERROR] = " ",
                        [vim.diagnostic.severity.WARN] = " ",
                        [vim.diagnostic.severity.HINT] = " ",
                        [vim.diagnostic.severity.INFO] = " ",
                    },
                },
                underline = true,
                update_in_insert = false,
                severity_sort = true,
            })

            local on_attach = function(_, bufnr)
                local keymap = vim.keymap.set
                local opts = { noremap = true, silent = true, buffer = bufnr }

                vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"

                -- ホバー（ボーダー付き）- lspsaga が効かない場合のフォールバック
                keymap("n", "K", function()
                    vim.lsp.buf.hover({ border = "rounded" })
                end, opts)
                keymap("n", "<C-k>", function()
                    vim.lsp.buf.signature_help({ border = "rounded" })
                end, opts)

                -- その他のキーマップ
                keymap("n", "<space>q", vim.diagnostic.setloclist, opts)
                keymap("n", "<space>wa", vim.lsp.buf.add_workspace_folder, opts)
                keymap("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, opts)
                keymap("n", "<space>wl", function()
                    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
                end, opts)
                keymap("n", "<space>D", vim.lsp.buf.type_definition, opts)
            end

            local capabilities = vim.tbl_deep_extend("force",
                vim.lsp.protocol.make_client_capabilities(),
                require('cmp_nvim_lsp').default_capabilities()
            )

            -- mason-lspconfig v2 で setup_handlers が廃止されたため、
            -- 全サーバー共通の設定は vim.lsp.config("*") で与える（Neovim 0.11 以降の作法）
            vim.lsp.config("*", {
                on_attach = on_attach,
                capabilities = capabilities,
            })

            -- 上の opts.servers に書いたサーバー個別の設定を反映する
            for server, config in pairs(opts.servers or {}) do
                vim.lsp.config(server, config)
            end

            -- mason で入れたサーバーは mason-lspconfig が自動で有効化する（automatic_enable）
            require("mason-lspconfig").setup()
            -- 起動時に開いたファイルにも LSP が付く。Neovim 0.12 の vim.lsp.enable が、
            -- FileType が発火済みのバッファに対して自分で起動し直すため
        end,
    },
    {
        "williamboman/mason.nvim",
        cmd = "Mason",
        keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
        build = ":MasonUpdate",
        opts = {
            ensure_installed = {
                -- lua
                "stylua",
                -- typescript
                -- "typescript-language-server",
                -- go
                "gofumpt",   -- Formatter
                "goimports", -- Formatter
                "gopls",     -- LSP
                -- misc
                "shfmt",
                -- python
                "flake8",
                "black",
                "debugpy"
            },
        },
        ---@param opts MasonSettings | {ensure_installed: string[]}
        config = function(_, opts)
            require("mason").setup(opts)
            local mr = require("mason-registry")
            mr:on("package:install:success", function()
                vim.defer_fn(function()
                    -- trigger FileType event to possibly load this newly installed LSP server
                    require("lazy.core.handler.event").trigger({
                        event = "FileType",
                        buf = vim.api.nvim_get_current_buf(),
                    })
                end, 100)
            end)
            local function ensure_installed()
                for _, tool in ipairs(opts.ensure_installed) do
                    local p = mr.get_package(tool)
                    -- 入れている途中のものをもう一度入れようとすると、mason がエラーにする。
                    -- 新しいマシンでの初回の起動で、この関数が 2 回呼ばれて起きていた
                    if not p:is_installed() and not p:is_installing() then
                        p:install()
                    end
                end
            end
            if mr.refresh then
                mr.refresh(ensure_installed)
            else
                ensure_installed()
            end
        end,
    },
}
