return {
    {
        "nvim-telescope/telescope.nvim",
        cmd = "Telescope",
        version = false,
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-telescope/telescope-fzf-native.nvim",
            "delphinus/telescope-memo.nvim"
        },
        keys = {
            { ";r",  function() require("telescope.builtin").live_grep() end,                                      desc = "Grep (root dir)" },
            { ";f",  function() require("telescope.builtin").find_files({ no_ignore = false, hidden = true }) end, desc = "Find Files (root dir)" },
            { ";cb", "<cmd>Telescope buffers sort_mru=true sort_lastused=true<cr>",                                desc = "Buffers" },
            { ";of", "<cmd>Telescope oldfiles<cr>",                                                                desc = "Recent" },
            { ";gc", "<cmd>Telescope git_commits<CR>",                                                             desc = "commits" },
            { ";gs", "<cmd>Telescope git_status<CR>",                                                              desc = "status" },
            { ";s",  "<cmd>Telescope current_buffer_fuzzy_find<cr>",                                               desc = "Buffer" },
            { ";d",  "<cmd>Telescope diagnostics bufnr=0<cr>",                                                     desc = "Document diagnostics" },
            { ";D",  "<cmd>Telescope diagnostics<cr>",                                                             desc = "Workspace diagnostics" },
            { ";h",  "<cmd>Telescope help_tags<cr>",                                                               desc = "Help Pages" },
            { ";k",  "<cmd>Telescope keymaps<cr>",                                                                 desc = "Key Maps" },
        },
        opts = function()
            local actions = require("telescope.actions")

            local open_with_trouble = function(...)
                return require("trouble.providers.telescope").open_with_trouble(...)
            end
            local open_selected_with_trouble = function(...)
                return require("trouble.providers.telescope").open_selected_with_trouble(...)
            end

            require("telescope").load_extension("fzf")
            require("telescope").load_extension("memo")

            return {
                defaults = {
                    prompt_prefix = " ",
                    selection_caret = " ",
                    get_selection_window = function()
                        local wins = vim.api.nvim_list_wins()
                        table.insert(wins, 1, vim.api.nvim_get_current_win())
                        for _, win in ipairs(wins) do
                            local buf = vim.api.nvim_win_get_buf(win)
                            if vim.bo[buf].buftype == "" then
                                return win
                            end
                        end
                        return 0
                    end,
                    mappings = {
                        i = {
                            ["<c-t>"] = open_with_trouble,
                            ["<a-t>"] = open_selected_with_trouble,
                            ["<C-f>"] = actions.preview_scrolling_down,
                            ["<C-b>"] = actions.preview_scrolling_up,
                        },
                        n = {
                            ["q"] = actions.close,
                        },
                    },
                },
            }
        end,
    },
    {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        enabled = vim.fn.executable("make") == 1,
        dependencies = {
            "nvim-telescope/telescope.nvim"
        }
    }
}
