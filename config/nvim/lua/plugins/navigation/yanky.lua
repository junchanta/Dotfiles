-- =============================================================================
-- yanky.nvim - yank履歴管理
-- =============================================================================
--
-- 【使い方】
--   p / P         : 通常のペースト
--   <C-n>         : ペースト後、次の履歴に切り替え
--   <C-p>         : ペースト後、前の履歴に切り替え
--   <Space>yh     : Telescopeでyank履歴を検索・選択
--
-- 【Tips】
--   - yankした後にddしても、<C-p>でyank内容に戻れる
--   - "0p を覚えなくても大丈夫
--
-- =============================================================================

return {
    "gbprod/yanky.nvim",
    dependencies = { "nvim-telescope/telescope.nvim" },
    event = "VeryLazy",
    keys = {
        { "p", "<Plug>(YankyPutAfter)", mode = { "n", "x" }, desc = "ペースト（後）" },
        { "P", "<Plug>(YankyPutBefore)", mode = { "n", "x" }, desc = "ペースト（前）" },
        { "gp", "<Plug>(YankyGPutAfter)", mode = { "n", "x" }, desc = "ペースト（後）+ カーソル移動" },
        { "gP", "<Plug>(YankyGPutBefore)", mode = { "n", "x" }, desc = "ペースト（前）+ カーソル移動" },
        { "<C-n>", "<Plug>(YankyNextEntry)", desc = "次のyank履歴" },
        { "<C-p>", "<Plug>(YankyCycleBackward)", desc = "前のyank履歴" },
        { "<Space>yh", "<Cmd>Telescope yank_history<CR>", desc = "Yank履歴（Telescope）" },
    },
    opts = {
        ring = {
            history_length = 50,
            storage = "shada",
            sync_with_numbered_registers = true,
        },
        highlight = {
            on_put = true,
            on_yank = true,
            timer = 200,
        },
    },
    config = function(_, opts)
        require("yanky").setup(opts)
        require("telescope").load_extension("yank_history")
    end,
}
