-- ターミナル切り替え用のヘルパー関数
local function smart_toggle(target_id)
    return function()
        local terms = require("toggleterm.terminal").get_all()
        for _, term in ipairs(terms) do
            if term:is_open() and term.id ~= target_id then
                term:close()
            end
        end
        vim.cmd(target_id .. "ToggleTerm")
    end
end

return {
    -- terminal
    -- 使い方:
    --   <C-r>i       : ターミナル1をトグル
    --   <C-r>1 ~ 4   : ターミナル1~4に切り替え（他は自動で非表示）
    --   <C-r>s       : ターミナル一覧から選択
    --   <C-r>g       : lazygit を開く
    {
        "akinsho/toggleterm.nvim",
        version = false,
        keys = {
            { "<c-r>i", "<cmd>1ToggleTerm<CR>", mode = { "n", "t" }, desc = "Toggle Terminal 1" },
            { "<c-r>1", smart_toggle(1), mode = { "n", "t" }, desc = "Switch to Terminal 1" },
            { "<c-r>2", smart_toggle(2), mode = { "n", "t" }, desc = "Switch to Terminal 2" },
            { "<c-r>3", smart_toggle(3), mode = { "n", "t" }, desc = "Switch to Terminal 3" },
            { "<c-r>4", smart_toggle(4), mode = { "n", "t" }, desc = "Switch to Terminal 4" },
            { "<c-r>s", "<cmd>TermSelect<CR>", mode = { "n", "t" }, desc = "Select Terminal" },
            { "<c-r>g", desc = "Toggle Lazygit" },
        },
        config = function()
            require("toggleterm").setup {
                -- size can be a number or function which is passed the current terminal
                function(term)
                    if term.direction == "horizontal" then
                        return 15
                    elseif term.direction == "vertical" then
                        return vim.o.columns * 0.4
                    end
                end,
                hide_numbers = true,    -- hide the number column in toggleterm buffers
                autochdir = false,      -- when neovim changes it current directory the terminal will change it's own when next it's opened
                shade_terminals = true, -- NOTE: this option takes priority over highlights specified so if you specify Normal highlights you should set this to false
                start_in_insert = true,
                insert_mappings = true, -- whether or not the open mapping applies in insert mode
                persist_size = true,
                persist_mode = true,    -- if set to true (default) the previous terminal mode will be remembered
                --direction = 'vertical' | 'horizontal' | 'tab' | 'float',
                direction = 'float',
                close_on_exit = true, -- close the terminal window when the process exits
                shell = vim.o.shell,  -- change the default shell
                auto_scroll = true,   -- automatically scroll to the bottom on terminal output
                -- This field is only relevant if direction is set to 'float'
                float_opts = {
                    border = 'single',
                    winblend = 3,
                },
                winbar = {
                    enabled = false,
                    name_formatter = function(term) --  term: Terminal
                        return term.name
                    end
                },
            }

            -- integration lazygit
            local Terminal = require("toggleterm.terminal").Terminal
            local lazygit = Terminal:new({
                cmd = "lazygit",
                direction = "float",
                hidden = true,
                count = 7
            })

            function _lazygit_toggle()
                lazygit:toggle()
            end

            vim.keymap.set("n", "<c-r>g", _lazygit_toggle, { noremap = true, silent = true, desc = "Toggle Lazygit" })
        end,
    }
}
