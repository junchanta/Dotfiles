return {
    {
        "glidenote/memolist.vim",
        cmd = { "MemoNew" },
        dependencies = {
            "nvim-telescope/telescope.nvim",
        },
        config = function()
            vim.g.memolist_path = "$HOME/Work/memo"
            vim.g.memolist_memo_suffix = "md"
            vim.g.memolist_fzf = 1

            -- vim.api.nvim_set_keymap('', '<c-m>n', '<Plug>MemoNew', {})
            -- vim.api.nvim_set_keymap('', '<c-m>l', '<Plug>Telescope memo list', {})
            -- vim.api.nvim_set_keymap('', '<c-m>g', '<Plug>Telescope memo live_grep', {})

        end,
        keys = {
            { "<c-m>n", "<cmd>MemoNew<cr>" },
            { "<c-m>l", "<cmd>Telescope memo list<cr>" },
            { "<c-m>g", "<cmd>Telescope memo live_grep<cr>" },
        }
    }
}
