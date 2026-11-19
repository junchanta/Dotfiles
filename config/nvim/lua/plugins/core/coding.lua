return {
    -- snippets
    {
        "L3MON4D3/LuaSnip",
        dependencies = {
            "rafamadriz/friendly-snippets",
            config = function()
                require("luasnip.loaders.from_vscode").lazy_load()
            end,
        },
        opts = {
            history = true,
            delete_check_events = "TextChanged",
        },
        -- stylua: ignore
        keys = {
            {
                "<tab>",
                function()
                    return require("luasnip").jumpable(1) and "<Plug>luasnip-jump-next" or "<tab>"
                end,
                expr = true,
                silent = true,
                mode = "i",
            },
            { "<tab>",   function() require("luasnip").jump(1) end,  mode = "s" },
            { "<s-tab>", function() require("luasnip").jump(-1) end, mode = { "i", "s" } },
        },
    },
    -- アイコン表示用
    {
        "onsails/lspkind.nvim",
        lazy = true,
    },
    -- auto completion
    {
        "hrsh7th/nvim-cmp",
        version = false,
        event = "InsertEnter",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "saadparwaiz1/cmp_luasnip",
            "onsails/lspkind.nvim",
        },
        opts = function()
            vim.api.nvim_set_hl(0, "CmpGhostText", { link = "Comment", default = true })
            local cmp = require("cmp")
            local lspkind = require("lspkind")
            local defaults = require("cmp.config.default")()
            local has_words_before = function()
                if vim.bo[0].buftype == "prompt" then return false end
                local line, col = unpack(vim.api.nvim_win_get_cursor(0))
                return col ~= 0 and vim.api.nvim_buf_get_text(0, line-1, 0, line-1, col, {})[1]:match("^%s*$") == nil
            end
            return {
                completion = {
                    completeopt = "menu,menuone,noinsert",
                },
                -- ウィンドウの見た目
                window = {
                    completion = cmp.config.window.bordered({
                        border = "rounded",
                        winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None",
                    }),
                    documentation = cmp.config.window.bordered({
                        border = "rounded",
                        winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
                    }),
                },
                -- アイコンとソース名の表示
                formatting = {
                    format = lspkind.cmp_format({
                        mode = "symbol_text",
                        maxwidth = 50,
                        ellipsis_char = "...",
                        symbol_map = { Copilot = "" },
                        before = function(entry, vim_item)
                            -- ソース名を表示
                            vim_item.menu = ({
                                nvim_lsp = "[LSP]",
                                copilot = "[Copilot]",
                                luasnip = "[Snippet]",
                                buffer = "[Buffer]",
                                path = "[Path]",
                            })[entry.source.name]
                            return vim_item
                        end,
                    }),
                },
                snippet = {
                    expand = function(args)
                        require("luasnip").lsp_expand(args.body)
                    end,
                },
                mapping = cmp.mapping.preset.insert({
                    ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
                    ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
                    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
                    ["<C-f>"] = cmp.mapping.scroll_docs(4),
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ["<C-e>"] = cmp.mapping.abort(),
                    ["<CR>"] = cmp.mapping.confirm({ select = true }),
                    ["<S-CR>"] = cmp.mapping.confirm({
                        behavior = cmp.ConfirmBehavior.Replace,
                        select = true,
                    }),
                    ["<C-CR>"] = function(fallback)
                        cmp.abort()
                        fallback()
                    end,
                    ["<Tab>"] = vim.schedule_wrap(function(fallback)
                        if cmp.visible() and has_words_before() then
                          cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
                        else
                          fallback()
                        end
                    end),
                }),
                sources = cmp.config.sources({
                    { name = "nvim_lsp" },
                    { name = "copilot" },
                    { name = "luasnip" },
                    { name = "path" },
                }, {
                    { name = "buffer" },
                }),
                experimental = {
                    ghost_text = {
                        hl_group = "CmpGhostText",
                    },
                },
                sorting = defaults.sorting,
            }
        end,
        ---@param opts cmp.ConfigSchema
        config = function(_, opts)
            for _, source in ipairs(opts.sources) do
                source.group_index = source.group_index or 1
            end
            require("cmp").setup(opts)
        end,
    },
    -- Comment
    {
        'echasnovski/mini.comment',
        version = false,
        opts = {
            -- Options which control module behavior
            options = {
                -- Function to compute custom 'commentstring' (optional)
                custom_commentstring = nil,

                -- Whether to ignore blank lines
                ignore_blank_line = true,

                -- Whether to recognize as comment only lines without indent
                start_of_line = false,

                -- Whether to ensure single space pad for comment parts
                pad_comment_parts = true,
            },
            -- Module mappings. Use `''` (empty string) to disable one.
            mappings = {
                -- Toggle comment (like `gcip` - comment inner paragraph) for both
                -- Normal and Visual modes
                comment = 'gc',

                -- Toggle comment on current line
                comment_line = 'gcc',

                -- Toggle comment on visual selection
                comment_visual = 'gc',

                -- Define 'comment' textobject (like `dgc` - delete whole comment block)
                textobject = 'gc',
            },

            -- Hook functions to be executed at certain stage of commenting
            hooks = {
                -- Before successful commenting. Does nothing by default.
                pre = function() end,
                -- After successful commenting. Does nothing by default.
                post = function() end,
            },
        },
        config = function()
            require('mini.comment').setup()
        end
    },
    -- Auto Pair
    {
        'echasnovski/mini.pairs',
        version = false,
        opts = {
            -- In which modes mappings from this `config` should be created
            modes = { insert = true, command = false, terminal = false },

            -- Global mappings. Each right hand side should be a pair information, a
            -- table with at least these fields (see more in |MiniPairs.map|):
            -- - <action> - one of 'open', 'close', 'closeopen'.
            -- - <pair> - two character string for pair to be used.
            -- By default pair is not inserted after `\`, quotes are not recognized by
            -- `<CR>`, `'` does not insert pair after a letter.
            -- Only parts of tables can be tweaked (others will use these defaults).
            mappings = {
                ['('] = { action = 'open', pair = '()', neigh_pattern = '[^\\].' },
                ['['] = { action = 'open', pair = '[]', neigh_pattern = '[^\\].' },
                ['{'] = { action = 'open', pair = '{}', neigh_pattern = '[^\\].' },

                [')'] = { action = 'close', pair = '()', neigh_pattern = '[^\\].' },
                [']'] = { action = 'close', pair = '[]', neigh_pattern = '[^\\].' },
                ['}'] = { action = 'close', pair = '{}', neigh_pattern = '[^\\].' },

                ['"'] = { action = 'closeopen', pair = '""', neigh_pattern = '[^\\].', register = { cr = false } },
                ["'"] = { action = 'closeopen', pair = "''", neigh_pattern = '[^%a\\].', register = { cr = false } },
                ['`'] = { action = 'closeopen', pair = '``', neigh_pattern = '[^\\].', register = { cr = false } },
            },
        },
        config = function()
            require('mini.pairs').setup()
        end
    },
    -- surround
    {
        "echasnovski/mini.surround",
        version = false,
        config = function()
            require("mini.surround").setup({
                -- Add custom surroundings to be used on top of builtin ones. For more
                -- information with examples, see `:h MiniSurround.config`.
                custom_surroundings = nil,

                -- Duration (in ms) of highlight when calling `MiniSurround.highlight()`
                highlight_duration = 500,

                -- Module mappings. Use `''` (empty string) to disable one.
                mappings = {
                    add = 'gza',            -- Add surrounding in Normal and Visual modes
                    delete = 'gzd',         -- Delete surrounding
                    find = 'gzf',           -- Find surrounding (to the right)
                    find_left = 'gzh',      -- Find surrounding (to the left)
                    highlight = 'gzH',      -- Highlight surrounding
                    replace = 'gzr',        -- Replace surrounding
                    update_n_lines = 'gzu', -- Update `n_lines`
                },

                -- Number of lines within which surrounding is searched
                n_lines = 20,

                -- Whether to respect selection type:
                -- - Place surroundings on separate lines in linewise mode.
                -- - Place surroundings on each line in blockwise mode.
                respect_selection_type = false,

                -- How to search for surrounding (first inside current line, then inside
                -- neighborhood). One of 'cover', 'cover_or_next', 'cover_or_prev',
                -- 'cover_or_nearest', 'next', 'prev', 'nearest'. For more details,
                -- see `:h MiniSurround.config`.
                search_method = 'cover',

                -- Whether to disable showing non-error feedback
                silent = false,
            })
        end
    },
    -- NOTE: easymotion は flash.nvim に移行済み
    -- 設定は navigation/flash.lua を参照
}
