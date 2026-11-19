-- =============================================================================
-- flash.nvim - 高速ナビゲーションプラグイン
-- =============================================================================
--
-- 【基本的な使い方】
--
-- ■ ジャンプ (easymotion互換)
--   m        : 文字を入力 → ラベル表示 → ラベル押下でジャンプ
--   M        : Treesitterノード選択（関数、if文などの構文単位で選択）
--
-- ■ 検索統合
--   /pattern : 通常検索 + 全マッチにラベル表示 → ラベルで即ジャンプ
--   ?pattern : 逆方向検索 + ラベル表示
--
-- ■ 拡張 f/t モーション
--   f{char}  : 画面内の全ての {char} にラベル表示（複数行対応）
--   F{char}  : 逆方向
--   t{char}  : {char} の手前までジャンプ（複数行対応）
--   T{char}  : 逆方向
--
-- ■ リモート操作（ジャンプせずに離れた場所を操作）
--   yr       : remote yank - ラベル選択した場所をyank（カーソルは動かない）
--   dr       : remote delete - ラベル選択した場所をdelete
--
-- ■ Treesitter選択モード (M)
--   ラベル選択後:
--     ;      : 選択範囲を親要素に拡大
--     ,      : 選択範囲を子要素に縮小
--
-- =============================================================================

return {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {
        -- ラベルに使う文字（押しやすい順）
        labels = "asdfghjklqwertyuiopzxcvbnm",
        search = {
            -- 検索モード: "exact" | "search" | "fuzzy"
            mode = "exact",
            -- 大文字小文字を区別しない
            incremental = true,
        },
        jump = {
            -- ジャンプ後に検索ハイライトを消す
            nohlsearch = true,
            -- ジャンプ履歴に追加
            jumplist = true,
            -- 自動ジャンプを無効化（常にラベル選択）
            autojump = false,
        },
        label = {
            -- ラベルを単語の後ろではなく前に表示
            after = false,
            before = true,
            -- ラベルの見た目
            uppercase = false,
            -- 現在行のラベルを優先
            current = true,
            -- ラベルを虹色にしない
            rainbow = {
                enabled = false,
            },
            -- マッチが多い場合、遠い位置でも必ずラベルを表示
            reuse = "none",
        },
        modes = {
            -- /検索統合
            search = {
                enabled = true,
                search = {
                    -- ラベルを振らないウィンドウ（flash 既定値 + Neogit の status 画面）。
                    -- Neogit では素の / インクリメンタル検索を使いたいので除外する。
                    -- ここ（modes.search）に書くことで m ジャンプや f/t には影響させない
                    exclude = {
                        "notify",
                        "cmp_menu",
                        "noice",
                        "flash_prompt",
                        "NeogitStatus",
                        function(win)
                            -- exclude non-focusable windows
                            return not vim.api.nvim_win_get_config(win).focusable
                        end,
                    },
                },
            },
            -- 文字ジャンプ（f/t拡張）
            char = {
                enabled = true,
                -- f/tの後、; で次へ、, で前へ
                keys = { "f", "F", "t", "T", ";", "," },
                -- 複数行対応
                multi_line = true,
                -- ラベル表示する（falseなら ; で移動）
                jump_labels = true,
                -- ハイライト
                highlight = { backdrop = true },
            },
            -- Treesitter選択
            treesitter = {
                labels = "asdfghjklqwertyuiop",
                jump = { pos = "range" },
                search = { incremental = false },
                label = { before = true, after = true, style = "inline" },
                highlight = {
                    backdrop = false,
                    matches = false,
                },
            },
        },
        -- 半透明背景でラベルを見やすく
        highlight = {
            backdrop = true,
        },
    },
    keys = {
        -- ■ 基本ジャンプ（easymotion互換: m キー）
        {
            "m",
            mode = { "n", "x", "o" },
            function()
                require("flash").jump()
            end,
            desc = "Flash: ジャンプ",
        },
        -- ■ Treesitter選択（構文単位で選択）
        {
            "M",
            mode = { "n", "x", "o" },
            function()
                require("flash").treesitter()
            end,
            desc = "Flash: Treesitter選択",
        },
        -- ■ リモート操作（ジャンプせずに操作）
        {
            "r",
            mode = "o",
            function()
                require("flash").remote()
            end,
            desc = "Flash: リモート操作",
        },
        -- ■ Treesitter検索（Visual/Operatorモード）
        {
            "R",
            mode = { "o", "x" },
            function()
                require("flash").treesitter_search()
            end,
            desc = "Flash: Treesitter検索",
        },
        -- ■ 検索モードでflashトグル
        {
            "<c-s>",
            mode = { "c" },
            function()
                require("flash").toggle()
            end,
            desc = "Flash: 検索モードトグル",
        },
    },
}
