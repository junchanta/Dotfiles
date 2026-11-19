return {
    -- カラーコードをハイライト表示
    {
        "NvChad/nvim-colorizer.lua",
        event = "BufReadPost",
        opts = {
            user_default_options = {
                names = false,    -- "red" などの名前は無効
                RGB = true,       -- #RGB
                RRGGBB = true,    -- #RRGGBB
                css = true,       -- css関数 rgb(), hsl()
                tailwind = true,  -- Tailwind CSS
            },
        },
    },
    -- tokyonight
    {
        "folke/tokyonight.nvim",
        lazy = false,
        priority = 1000,
        config = function()
            vim.cmd([[colorscheme tokyonight-night]])

            -- カスタムハイライト設定
            vim.cmd("highlight LineNr guibg=NONE guifg=#005f5f")
            vim.cmd("highlight CursorLineNr guibg=NONE guifg=#008787")
            vim.cmd("highlight CursorLine gui=underline guifg=None guibg=NONE")

            -- ウィンドウ境界線を見やすく
            vim.cmd("highlight WinSeparator guifg=#7aa2f7 guibg=NONE")

            -- ステータスライン（グローバル、画面最下部）
            vim.cmd("highlight StatusLine guibg=#292e42 guifg=#c0caf5")

            -- winbar（各ウィンドウ上部のタイトルバー）- 柔らかめの色
            vim.cmd("highlight WinBar guibg=#1f2335 guifg=#7aa2f7")
            vim.cmd("highlight WinBarNC guibg=#16161e guifg=#565f89")
            -- winbar の下線（コードとの境界）
            vim.cmd("highlight WinSeparator guifg=#3b4261 guibg=NONE")

            -- diff の配色
            -- tokyonight 既定の git 色（add=#449dab / delete=#914c54）は彩度が低く、
            -- 追加行が青緑に寄って見えるため、緑・赤をはっきりさせた濃いめの色に置き換える
            -- 土台（diffview・vimdiff がこれを使う）
            vim.cmd("highlight DiffAdd    guibg=#1e3a28 guifg=NONE")
            vim.cmd("highlight DiffDelete guibg=#3f2028 guifg=NONE")
            vim.cmd("highlight DiffChange guibg=#1f2a3f guifg=NONE")
            vim.cmd("highlight DiffText   guibg=#2d4a7a guifg=NONE")
            -- Neogit（無印=通常、Highlight=カーソルのある項目、Cursor=カーソル行）
            vim.cmd("highlight NeogitDiffAdd              guibg=#1e3a28 guifg=#8fd46a")
            vim.cmd("highlight NeogitDiffAddHighlight     guibg=#26492f guifg=#b9f27c")
            vim.cmd("highlight NeogitDiffAddCursor        guibg=#26492f guifg=#b9f27c")
            vim.cmd("highlight NeogitDiffDelete           guibg=#3f2028 guifg=#e06c78")
            vim.cmd("highlight NeogitDiffDeleteHighlight  guibg=#4d2530 guifg=#ff7a93")
            vim.cmd("highlight NeogitDiffDeleteCursor     guibg=#4d2530 guifg=#ff7a93")
            vim.cmd("highlight NeogitDiffContext          guibg=#1a1b26 guifg=NONE")
            vim.cmd("highlight NeogitDiffContextHighlight guibg=#20222e guifg=#c0caf5")
            vim.cmd("highlight NeogitDiffContextCursor    guibg=#20222e guifg=#c0caf5")
            -- 行内の変更箇所（word diff）
            vim.cmd("highlight NeogitDiffAddInline        guibg=#3d7a4a guifg=#e6f5da")
            vim.cmd("highlight NeogitDiffDeleteInline     guibg=#8f2f3c guifg=#ffe0e4")
            -- hunk / ファイルの見出し
            vim.cmd("highlight NeogitHunkHeader           guibg=#252a3f guifg=#7aa2f7")
            vim.cmd("highlight NeogitHunkHeaderHighlight  guibg=#3b4261 guifg=#c0caf5")
            vim.cmd("highlight NeogitDiffHeader           guibg=#252a3f guifg=#7dcfff")
            vim.cmd("highlight NeogitDiffHeaderHighlight  guibg=#2f3550 guifg=#2ac3de")
        end,
    },
}
