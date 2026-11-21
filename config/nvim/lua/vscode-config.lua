require("bootstrap")

require("lazy").setup({
    {
        "echasnovski/mini.surround",
        version = false,
        -- まだ取得されていないマシンでは、読み込まない(エラーにしない)。
        -- ターミナルで nvim を起動すると取得され、次から読み込まれる
        cond = function()
            return vim.loop.fs_stat(vim.fn.stdpath("data") .. "/lazy/mini.surround") ~= nil
        end,
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
  }, {
    -- Cursor の中では、足りないプラグインを自動で取得しない。
    -- ここで取得すると、プラグインの版の記録(lazy-lock.json)が、この少数のプラグインだけの内容に書き換わる。
    -- プラグインは、ターミナルで nvim を起動したときに取得される
    install = { missing = false },
  })
