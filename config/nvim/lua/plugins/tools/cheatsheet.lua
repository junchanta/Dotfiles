-- =============================================================================
-- cheatsheet.nvim - キーバインド・コマンドのチートシート
-- =============================================================================
--
-- 【使い方】
--   <Space>?      : チートシートを開く（Telescope）
--   <Space>?で開いた後:
--     <CR>        : 選択したコマンドを実行
--     <C-e>       : 選択したコマンドを編集（コマンドラインに入力）
--
-- =============================================================================

return {
    "sudormrfbin/cheatsheet.nvim",
    dependencies = {
        "nvim-telescope/telescope.nvim",
        "nvim-lua/popup.nvim",
        "nvim-lua/plenary.nvim",
    },
    keys = {
        { "<Space>?", "<Cmd>Cheatsheet<CR>", desc = "チートシート" },
    },
    opts = {
        bundled_cheatsheets = false,   -- デフォルトのチートシートは無効
        bundled_plugin_cheatsheets = false,
        include_only_installed_plugins = true,
    },
}
