-- treesitter の highlight はグローバルでは無効（render-markdown の config で markdown バッファのみ有効化している）。
-- ロード順によっては未パースの場合があるため、markdown-togglecheck の呼び出し前に明示的にパースする
local function toggle_check(fn)
    return function()
        vim.treesitter.get_parser(0, "markdown"):parse(true)
        require("markdown-togglecheck")[fn]()
    end
end

return {
    {
        "iamcco/markdown-preview.nvim",
        cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
        -- ビルドには node(npm)が要る。まだないマシンではビルドを飛ばし、エラーにしない。
        -- node を入れた後に :Lazy build markdown-preview.nvim を実行すると入る
        build = function(plugin)
            if vim.fn.executable("npm") == 0 then
                vim.notify(
                    "markdown-preview.nvim: npm がないのでビルドを飛ばした。node を入れた後に :Lazy build markdown-preview.nvim を実行する",
                    vim.log.levels.WARN
                )
                return
            end
            local result = vim.system({ "npm", "install" }, { cwd = plugin.dir .. "/app", text = true }):wait()
            if result.code ~= 0 then
                error("markdown-preview.nvim のビルドに失敗した:\n" .. (result.stderr or ""))
            end
        end,
        init = function()
            vim.g.mkdp_filetypes = { "markdown" }
        end,
        ft = { "markdown" },
        keys = {
            {"mdp", "<Plug>MarkdownPreview"},
        }
    },
    {
        "MeanderingProgrammer/render-markdown.nvim",
        ft = { "markdown" },
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "nvim-tree/nvim-web-devicons",
        },
        opts = {
            -- 既定では挿入・ビジュアルモードに入ると画面全体が生テキストに戻るため、全モードで描画する
            render_modes = true,
            -- 既定の throttle は連続スクロール中の描画を捨てるため、生テキストが見えたままになる。毎回すぐ描画する
            debounce = 0,
            -- カーソル行だけ生テキストに戻す挙動は挿入モードに限る（ノーマル・ビジュアルで行がちらつかない）
            anti_conceal = {
                disabled_modes = { "n", "c", "t", "v", "V", "\22" },
            },
            win_options = {
                -- Neovim 側の conceal もカーソル行で外さない（挿入モードを除く）
                concealcursor = { rendered = "nvc" },
            },
            -- 装飾を控えめにする: 見出しは # を残してアイコン・サイン無し、背景は文字幅だけ
            heading = {
                sign = false,
                icons = {},
                width = "block",
                right_pad = 1,
            },
            code = {
                sign = false,
                width = "block",
                right_pad = 1,
            },
        },
        config = function(_, opts)
            -- render-markdown は treesitter highlight が有効なバッファでのみ描画されるため、
            -- markdown バッファに限定して有効化する
            vim.api.nvim_create_autocmd("FileType", {
                pattern = "markdown",
                group = vim.api.nvim_create_augroup("markdown_treesitter_highlight", {}),
                callback = function(ev)
                    vim.treesitter.start(ev.buf, "markdown")
                end,
            })
            for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].filetype == "markdown" then
                    vim.treesitter.start(buf, "markdown")
                end
            end
            require("render-markdown").setup(opts)
        end,
    },
    {
        'nfrid/markdown-togglecheck',
        ft = { 'markdown' },
        dependencies = {
            "nfrid/treesitter-utils",
        },
        keys = {
            { "<leader>x", toggle_check("toggle"), desc = "Toggle Checkmark", ft = "markdown" },
            { "<leader>X", toggle_check("toggle_box"), desc = "Toggle Checkbox", ft = "markdown" },
        },
        config = function ()
            -- markdown-togglecheck は、0.12 対応版の nvim-treesitter から消えた ts_utils に依存している。
            -- 使っている関数は get_node_at_cursor だけなので、Neovim 本体の同等の関数で代わりを用意する
            package.preload["nvim-treesitter.ts_utils"] = function()
                return {
                    get_node_at_cursor = function(_, ignore_injected_langs)
                        return vim.treesitter.get_node({ ignore_injections = ignore_injected_langs })
                    end,
                }
            end
            require('markdown-togglecheck').setup({
                -- create empty checkbox on item without any while toggling
                create = true,
                -- remove checked checkbox instead of unckecking it while toggling
                remove = true,
            })
        end
    }
}
