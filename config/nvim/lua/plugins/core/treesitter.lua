-- nvim-treesitter は Neovim 0.12 に対応した main ブランチを使う。
-- main ブランチでは、textobjects のキーを vim.keymap.set で自分で割り当てる。
-- パーサーを足すときは :TSInstall <言語>(tree-sitter CLI が必要。Nix で入れている)
return {
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        lazy = false, -- main ブランチは遅延読み込みに対応していない
        build = ":TSUpdate",
    },
    {
        "nvim-treesitter/nvim-treesitter-textobjects",
        branch = "main",
        event = "VeryLazy",
        config = function()
            require("nvim-treesitter-textobjects").setup({
                select = { lookahead = true },
                move = { set_jumps = true },
            })

            local function select(query)
                return function()
                    require("nvim-treesitter-textobjects.select").select_textobject(query, "textobjects")
                end
            end
            for key, query in pairs({
                ["af"] = "@function.outer",
                ["if"] = "@function.inner",
                ["ac"] = "@class.outer",
                ["ic"] = "@class.inner",
                ["iB"] = "@block.inner",
                ["aB"] = "@block.outer",
                ["ii"] = "@conditional.inner",
                ["ai"] = "@conditional.outer",
                ["il"] = "@loop.inner",
                ["al"] = "@loop.outer",
                ["ip"] = "@parameter.inner",
                ["ap"] = "@parameter.outer",
            }) do
                vim.keymap.set({ "x", "o" }, key, select(query))
            end

            local swap = require("nvim-treesitter-textobjects.swap")
            vim.keymap.set("n", "'>", function() swap.swap_next("@parameter.inner") end)
            vim.keymap.set("n", "'<", function() swap.swap_previous("@parameter.inner") end)

            local move = require("nvim-treesitter-textobjects.move")
            for key, args in pairs({
                ["]mm"] = { "goto_next_start", "@function.outer" },
                ["]]"] = { "goto_next_start", "@class.outer" },
                ["]M"] = { "goto_next_end", "@function.outer" },
                ["]["] = { "goto_next_end", "@class.outer" },
                ["[m"] = { "goto_previous_start", "@function.outer" },
                ["[["] = { "goto_previous_start", "@class.outer" },
                ["[M"] = { "goto_previous_end", "@function.outer" },
                ["[]"] = { "goto_previous_end", "@class.outer" },
            }) do
                vim.keymap.set({ "n", "x", "o" }, key, function()
                    move[args[1]](args[2], "textobjects")
                end)
            end
        end,
    },
}
