return {
    -- NOTE: copilot.lua をコメントアウト
    -- plenary.nvim の curl が GitHub API にアクセスする際、
    -- ネットワーク切断時に Neovim がフリーズする問題があるため無効化
    -- {
    --     "zbirenbaum/copilot.lua",
    --     lazy = true,
    --     event = "InsertEnter",
    --     config = function()
    --         require("copilot").setup({
    --             -- インライン提案は無効（cmp ポップアップを使用）
    --             suggestion = { enabled = false },
    --             panel = { enabled = false },
    --             copilot_node_command = 'node'
    --         })
    --     end
    -- },
    -- copilot-cmp: cmp ポップアップに Copilot 提案を表示
    -- インライン提案（ゴーストテキスト）を使いたい場合は、
    -- これをコメントアウトし、copilot.lua の suggestion.enabled = true にする
    -- {
    --     "zbirenbaum/copilot-cmp",
    --     dependencies = { "zbirenbaum/copilot.lua" },
    --     event = "InsertEnter",
    --     config = function()
    --         require("copilot_cmp").setup()
    --     end
    -- },
    -- claudecode.nvim: Claude Code とのIDE連携
    -- Neovim内のターミナルで Claude Code を起動し、WebSocket (IDEプロトコル) で接続する
    -- 使い方:
    --   <Space>cc : Claude Code をトグル
    --   <Space>cf : Claude Code ウィンドウにフォーカス
    --   <Space>cr : セッションを再開 (--resume)
    --   <Space>cC : 直前のセッションを継続 (--continue)
    --   <Space>cb : 現在のバッファをコンテキストに追加
    --   <Space>cs : (ビジュアルモード) 選択範囲を Claude に送信
    --   <Space>ca : Claude が提案した diff を承認
    --   <Space>cd : Claude が提案した diff を拒否
    {
        "coder/claudecode.nvim",
        keys = {
            { "<Space>cc", "<cmd>ClaudeCode<cr>", desc = "Claude Code をトグル" },
            { "<Space>cf", "<cmd>ClaudeCodeFocus<cr>", desc = "Claude Code にフォーカス" },
            { "<Space>cr", "<cmd>ClaudeCode --resume<cr>", desc = "Claude Code セッション再開" },
            { "<Space>cC", "<cmd>ClaudeCode --continue<cr>", desc = "Claude Code セッション継続" },
            { "<Space>cb", "<cmd>ClaudeCodeAdd %<cr>", desc = "現在のバッファを追加" },
            { "<Space>cs", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "選択範囲を Claude に送信" },
            { "<Space>ca", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "diff を承認" },
            { "<Space>cd", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "diff を拒否" },
        },
        opts = {
            terminal = {
                split_side = "right",
                split_width_percentage = 0.4,
                provider = "native", -- toggleterm 使用中のため snacks ではなく native を使う
            },
        },
    },

    -- nudge.nvim: 行・範囲にレビューコメントを付け、herdr 上の Claude Code ペインへまとめて送る
    -- herdr のペイン内で Neovim を起動していることが前提（$HERDR_PANE_ID を使う）
    -- コメントはメモリ上にだけ保持され、Neovim を終了すると消える
    -- 使い方:
    --   <Space>aa : 行（ビジュアルモードでは範囲）にコメント
    --   <Space>ae : カーソル下のコメントを編集
    --   <Space>ad : カーソル下のコメントを削除
    --   <Space>al : コメント一覧（quickfix）
    --   <Space>as : 全コメントを Claude Code に送る（Enter まで押して送信する。送信後にコメントは消える）
    --   <Space>at : 送信先ペインを選び直す
    --   :Nudge clear : 全コメントを削除
    {
        "imutaroh/nudge.nvim",
        cmd = "Nudge",
        keys = {
            { "<Space>aa", function() require("nudge").add() end, mode = { "n", "x" }, desc = "Nudge: コメントを付ける" },
            { "<Space>ae", function() require("nudge").edit() end, desc = "Nudge: コメントを編集" },
            { "<Space>ad", function() require("nudge").delete() end, desc = "Nudge: コメントを削除" },
            { "<Space>al", function() require("nudge").list() end, desc = "Nudge: コメント一覧" },
            { "<Space>as", function() require("nudge").send() end, desc = "Nudge: Claude Code に送る" },
            { "<Space>at", function() require("nudge").target() end, desc = "Nudge: 送信先を選び直す" },
        },
        opts = {
            submit = true, -- 貼り付けたあと Enter も押して送信する
        },
    },
}
