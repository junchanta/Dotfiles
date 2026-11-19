-- =============================================================================
-- nvim-hlslens - 検索マッチ数と位置を表示
-- =============================================================================
--
-- 【使い方】
--   /pattern   : 検索すると [1/10] のようにマッチ数を表示
--   n / N      : 次/前のマッチに移動（位置情報も更新）
--   * / #      : カーソル下の単語を検索
--   <Space>x   : 検索ハイライトをクリア
--   5n         : 5番目の次のマッチにジャンプ
--
-- =============================================================================

return {
    "kevinhwang91/nvim-hlslens",
    event = "CmdlineEnter",
    keys = {
        {
            "n",
            [[<Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>]],
            desc = "次の検索結果",
            silent = true,
        },
        {
            "N",
            [[<Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>]],
            desc = "前の検索結果",
            silent = true,
        },
        {
            "*",
            [[*<Cmd>lua require('hlslens').start()<CR>]],
            desc = "カーソル下の単語を検索（前方）",
            silent = true,
        },
        {
            "#",
            [[#<Cmd>lua require('hlslens').start()<CR>]],
            desc = "カーソル下の単語を検索（後方）",
            silent = true,
        },
        {
            "g*",
            [[g*<Cmd>lua require('hlslens').start()<CR>]],
            desc = "カーソル下の単語を部分検索（前方）",
            silent = true,
        },
        {
            "g#",
            [[g#<Cmd>lua require('hlslens').start()<CR>]],
            desc = "カーソル下の単語を部分検索（後方）",
            silent = true,
        },
        {
            "<Space>x",
            "<Cmd>noh<CR>",
            desc = "検索ハイライトをクリア",
            silent = true,
        },
    },
    opts = {
        calm_down = true,           -- カーソル移動でハイライトを薄くする
        nearest_only = false,       -- 最も近いマッチだけでなく全てに表示
        nearest_float_when = "auto", -- フロートウィンドウで表示
    },
}
