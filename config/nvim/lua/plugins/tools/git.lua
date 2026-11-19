return {
    {
        "lewis6991/gitsigns.nvim",
        event = "VeryLazy",
        opts = {
            signs = {
                add = { text = "▎" },
                change = { text = "▎" },
                delete = { text = "" },
                topdelete = { text = "" },
                changedelete = { text = "▎" },
                untracked = { text = "▎" },
            },
            on_attach = function(buffer)
                local gs = package.loaded.gitsigns

                local function map(mode, l, r, desc)
                    vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
                end

                -- stylua: ignore start
                map("n", "]h", gs.next_hunk, "Next Hunk")
                map("n", "[h", gs.prev_hunk, "Prev Hunk")
                map({ "n", "v" }, "<leader>ghs", ":Gitsigns stage_hunk<CR>", "Stage Hunk")
                map({ "n", "v" }, "<leader>ghr", ":Gitsigns reset_hunk<CR>", "Reset Hunk")
                map("n", "<leader>ghS", gs.stage_buffer, "Stage Buffer")
                map("n", "<leader>ghu", gs.undo_stage_hunk, "Undo Stage Hunk")
                map("n", "<leader>ghR", gs.reset_buffer, "Reset Buffer")
                map("n", "<leader>ghp", gs.preview_hunk, "Preview Hunk")
                map("n", "<leader>ghb", function() gs.blame_line({ full = true }) end, "Blame Line")
                map("n", "<leader>ghd", gs.diffthis, "Diff This")
                map("n", "<leader>ghD", function() gs.diffthis("~") end, "Diff This ~")
                map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk")
            end,
        },
    },

    -- 差分・履歴ビューア（float ではなくタブページを使う）
    -- 使い方:
    --   <leader>gd   : 作業ツリーの差分
    --   <leader>gD   : ブランチ全体の差分（origin/HEAD...HEAD）
    --   <leader>gf/F : このファイル / リポジトリのコミット履歴
    --   差分内で  q : 閉じる、<leader>b : ファイルパネルの開閉
    {
        "sindrets/diffview.nvim",
        cmd = { "DiffviewOpen", "DiffviewFileHistory" },
        keys = {
            { "<leader>gd", "<cmd>DiffviewOpen<CR>",                    desc = "Diff: 作業ツリー" },
            { "<leader>gD", "<cmd>DiffviewOpen origin/HEAD...HEAD<CR>", desc = "Diff: ブランチ全体" },
            { "<leader>gf", "<cmd>DiffviewFileHistory %<CR>",           desc = "Diff: このファイルの履歴" },
            { "<leader>gF", "<cmd>DiffviewFileHistory<CR>",             desc = "Diff: リポジトリの履歴" },
        },
        opts = {
            enhanced_diff_hl = true,
            view = {
                -- 画面幅が狭い運用なので上下分割。横並びに戻すなら diff2_horizontal
                default = { layout = "diff2_vertical" },
                file_history = { layout = "diff2_vertical" },
                merge_tool = { layout = "diff3_mixed" },
            },
            file_panel = {
                listing_style = "tree",
                win_config = { width = 28 },
            },
            keymaps = {
                view = { { "n", "q", "<cmd>DiffviewClose<CR>", { desc = "閉じる" } } },
                file_panel = { { "n", "q", "<cmd>DiffviewClose<CR>", { desc = "閉じる" } } },
            },
        },
    },

    -- magit ライクな Git 操作 UI（バッファベース、タブページで開く）
    -- 使い方:
    --   <leader>gg   : status を開く（s: stage, u: unstage, c c: commit, p p: push）
    --   <leader>gc   : commit を直接開く
    --   status 内で a        : 差分の展開・折りたたみ
    --              za       : 全てを畳む（zO: 全てを展開）
    --              <Space>z : セクション内の hunk を一括で折りたたむ
    --              T        : 新しいタブで該当行を開く（既定の <C-t> の代替）
    --              d d      : diffview で開く
    {
        "NeogitOrg/neogit",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "sindrets/diffview.nvim",
            "nvim-telescope/telescope.nvim",
        },
        cmd = "Neogit",
        keys = {
            { "<leader>gg", "<cmd>Neogit<CR>",        desc = "Neogit" },
            { "<leader>gc", "<cmd>Neogit commit<CR>", desc = "Neogit: commit" },
        },
        init = function()
            -- 閉じた fold（= 展開していないファイル行）は Vim の仕様で折り返せず、
            -- 右端で切れて肝心のファイル名が読めない。そこで foldtext を差し替え、
            -- 幅に収まらないときだけパスを s/u/s/… 形式に縮めて表示する
            _G.NeogitFoldText = function()
                local lnum = vim.v.foldstart
                local line = vim.fn.getline(lnum)
                local win = vim.api.nvim_get_current_win()
                local buf = vim.api.nvim_win_get_buf(win)

                -- foldtext を空にしたときと同じ色を保つため、行のハイライトを extmark から復元する
                local chunks, col = {}, 0
                local marks = vim.api.nvim_buf_get_extmarks(
                    buf, -1, { lnum - 1, 0 }, { lnum - 1, -1 }, { details = true }
                )
                for _, mark in ipairs(marks) do
                    local start_col, details = mark[3], mark[4]
                    local end_col, hl = details.end_col, details.hl_group
                    if hl and end_col and end_col > start_col and start_col >= col then
                        if start_col > col then
                            table.insert(chunks, { line:sub(col + 1, start_col) })
                        end
                        table.insert(chunks, { line:sub(start_col + 1, end_col), hl })
                        col = end_col
                    end
                end
                if col < #line then
                    table.insert(chunks, { line:sub(col + 1) })
                end

                -- 末尾のチャンク（パス）だけを縮める
                local last = chunks[#chunks]
                local width = vim.api.nvim_win_get_width(win) - vim.fn.getwininfo(win)[1].textoff
                if last and last[1]:find("/") and vim.fn.strdisplaywidth(line) > width then
                    local head = 0
                    for i = 1, #chunks - 1 do
                        head = head + vim.fn.strdisplaywidth(chunks[i][1])
                    end
                    local text = vim.fn.pathshorten(last[1])
                    if head + vim.fn.strdisplaywidth(text) > width then
                        text = "…" .. text:sub(-math.max(width - head - 1, 1))
                    end
                    last[1] = text
                end

                return chunks
            end

            -- Neogit はバッファ表示後に wrap=false を強制するため、
            -- FileType の後に schedule して上書きする
            vim.api.nvim_create_autocmd("FileType", {
                pattern = { "NeogitStatus", "NeogitCommitView", "NeogitDiffView", "NeogitLogView" },
                callback = function(args)
                    vim.schedule(function()
                        local win = vim.fn.bufwinid(args.buf)
                        if win ~= -1 then
                            vim.wo[win].wrap = true
                            vim.wo[win].breakindent = true -- 折り返し行のインデントを揃える
                            vim.wo[win].showbreak = "↳ "
                            vim.wo[win].foldtext = "v:lua.NeogitFoldText()"
                        end
                    end)
                end,
            })

            -- <C-x>/<C-v> は素の split/vsplit で開くため、既定だと新しい窓が
            -- 上・左に出て Neogit が押しやられる。status に居る間だけ
            -- splitbelow/splitright を立て、Neogit が上・左に残るようにする
            -- （Neogit 自身の popup 等は nvim_open_win の明示指定で開くため影響しない）
            vim.api.nvim_create_autocmd("FileType", {
                pattern = "NeogitStatus",
                callback = function(args)
                    if vim.b[args.buf].neogit_split_flip then
                        return
                    end
                    vim.b[args.buf].neogit_split_flip = true

                    local saved
                    local function flip()
                        -- BufLeave を挟まず BufEnter が連続することがあるため、
                        -- 未保存のときだけ元の値を取る（flip 後の値で上書きしない）
                        if saved == nil then
                            saved = { below = vim.o.splitbelow, right = vim.o.splitright }
                        end
                        vim.o.splitbelow = true
                        vim.o.splitright = true
                    end
                    local function restore()
                        if saved then
                            vim.o.splitbelow = saved.below
                            vim.o.splitright = saved.right
                            saved = nil
                        end
                    end

                    -- FileType 発火時点で既にこのバッファに居るため、初回は直接立てる
                    flip()
                    vim.api.nvim_create_autocmd("BufEnter", { buffer = args.buf, callback = flip })
                    vim.api.nvim_create_autocmd("BufLeave", { buffer = args.buf, callback = restore })
                end,
            })
        end,
        opts = {
            kind = "tab", -- float ではなくタブページで開く
            commit_editor = { kind = "split" },
            commit_view = { kind = "tab" }, -- 既定の vsplit は半画面だと狭すぎる
            integrations = {
                diffview = true,
                telescope = true,
            },
            mappings = {
                status = {
                    -- <Tab>/<S-Tab> はタブページ切り替え（グローバルマッピング）に使うため、
                    -- Neogit には割り当てない（read-only バッファなので a に append の意味はない）
                    ["<tab>"] = false,
                    ["a"] = "Toggle", -- 差分の展開・折りたたみ
                    ["za"] = "Depth1", -- 全てを畳む（既定の za=Toggle は a に移したので流用）
                    ["<space>z"] = "Depth2", -- セクション内の hunk を一括で畳む
                    -- <C-t> は tmux の prefix と衝突して Neovim まで届かないため T に移す
                    ["<c-t>"] = false,
                    ["T"] = "TabOpen", -- 新しいタブで該当行を開く
                },
            },
        },
    },
}
