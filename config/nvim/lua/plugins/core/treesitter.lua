return {
    -- Treesitter is a new parser generator tool that we can
    -- use in Neovim to power faster and more accurate
    -- syntax highlighting.
    {
        "nvim-treesitter/nvim-treesitter",
        version = false, -- last release is way too old and doesn't work on Windows
        build = ":TSUpdate",
        dependencies = {
            "nvim-treesitter/nvim-treesitter-textobjects",
        },
        cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
        opts = {
            textobjects = { -- syntax-aware textobjects
                select = {
                    enable = true,
                    disable = {},
                    lookahead = true,
                    keymaps = {
                        ["af"] = "@function.outer",
                        ["if"] = "@function.inner",
                        ["ac"] = "@class.outer",
                        ["ic"] = "@class.inner",
                        ["iB"] = "@block.inner",
                        ["aB"] = "@block.outer",
                        -- use sandwich
                        -- ["i"] = "@call.inner",
                        -- ["a"] = "@call.outer",
                        -- ["a"] = "@comment.outer",
                        -- ["iF"] = "@frame.inner",
                        -- ["oF"] = "@frame.outer",
                        ["ii"] = "@conditional.inner",
                        ["ai"] = "@conditional.outer",
                        ["il"] = "@loop.inner",
                        ["al"] = "@loop.outer",
                        ["ip"] = "@parameter.inner",
                        ["ap"] = "@parameter.outer",
                        -- ["iS"] = "@scopename.inner",
                        -- ["aS"] = "@statement.outer",
                    },
                },
                swap = {
                    enable = true,
                    swap_next = { ["'>"] = "@parameter.inner" },
                    swap_previous = { ["'<"] = "@parameter.inner" },
                },
                move = {
                    enable = true,
                    goto_next_start = { ["]mm"] = "@function.outer", ["]]"] = "@class.outer" },
                    goto_next_end = { ["]M"] = "@function.outer", ["]["] = "@class.outer" },
                    goto_previous_start = { ["[m"] = "@function.outer", ["[["] = "@class.outer" },
                    goto_previous_end = { ["[M"] = "@function.outer", ["[]"] = "@class.outer" },
                },
            },
            -- textsubjects = {
            -- 	enable = false,
            -- 	-- prev_selection = "Q",
            -- 	keymaps = {
            -- 		["."] = "textsubjects-smart",
            -- 		["<Tab>"] = "textsubjects-container-outer",
            -- 		["<S-Tab>"] = "textsubjects-container-inner",
            -- 	},
            -- },
        },
        config = function(_, opts)
            require("nvim-treesitter.configs").setup(opts)
        end
    },
    {
        "nvim-treesitter/nvim-treesitter-textobjects",
        version = false,
    }
}
