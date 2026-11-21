-- scripts/check から呼ばれる。
-- Neovim の設定が、実際の使い方(ファイルを開く、プラグインを読み込む、キーを押す)でエラーを出さないかを確かめる。
-- エラーがあれば内容を標準エラーに出し、終了コード 1 で終わる。
--
-- 単体での使い方:
--   DOTFILES_CHECK_DIR=<見本ファイルのある場所> nvim --headless "+luafile scripts/lib/nvim-check.lua"

local dir = assert(vim.env.DOTFILES_CHECK_DIR, "DOTFILES_CHECK_DIR が設定されていない")

-- 何かが止まっても、必ず終わるようにする
vim.defer_fn(function()
    io.stderr:write("90 秒たっても終わらなかった\n")
    vim.cmd("cquit 2")
end, 90000)

local problems = {}

-- プラグインが vim.notify を差し替えても拾えるように、通知を横取りして記録する
local function hook_notify()
    local original = vim.notify
    vim.notify = function(msg, level, opts)
        if (level or vim.log.levels.INFO) >= vim.log.levels.ERROR then
            problems[#problems + 1] = tostring(msg)
        end
        return original(msg, level, opts)
    end
end

-- イベントを処理しながら待つ
local function settle(ms)
    vim.wait(ms, function() return false end, 50)
end

-- 実際にキーを押したのと同じ経路(割り当てを通す)で入力する
local function press(keys)
    vim.api.nvim_feedkeys(vim.keycode(keys), "mx", false)
end

hook_notify()
settle(500)

-- 1. 種類の違うファイルを順に開く(ファイルの種類ごとに読み込まれるプラグインを動かす)
local files = vim.fn.sort(vim.fn.glob(dir .. "/sample.*", false, true))
assert(#files > 0, "見本ファイルがない: " .. dir)
for _, file in ipairs(files) do
    vim.cmd.edit(vim.fn.fnameescape(file))
    settle(1500)
end

-- 2. 画面が出た後に読み込まれるプラグイン(VeryLazy)を読み込む。画面のない状態では自動で起きない
vim.api.nvim_exec_autocmds("User", { pattern = "VeryLazy" })
settle(1000)

-- 3. キー操作を試す。設定を書き直した箇所で、プラグインの更新で壊れやすいものに絞る
--    Markdown のチェックボックスの切り替え(Space x)
vim.cmd.edit(vim.fn.fnameescape(dir .. "/sample.md"))
settle(500)
vim.api.nvim_win_set_cursor(0, { 3, 3 })
press("<Space>x")
settle(500)
local toggled = vim.api.nvim_buf_get_lines(0, 2, 3, false)[1]
if toggled ~= "- [x] todo" then
    problems[#problems + 1] = "Markdown のチェックボックスの切り替え(Space x)が動かない。行の内容: " .. tostring(toggled)
end
vim.cmd("edit!")

--    関数全体の選択(vaf)
vim.cmd.edit(vim.fn.fnameescape(dir .. "/sample.lua"))
settle(500)
vim.api.nvim_win_set_cursor(0, { 2, 2 })
press("vaf")
local first, last = vim.fn.line("v"), vim.fn.line(".")
press("<Esc>")
if math.min(first, last) ~= 1 or math.max(first, last) ~= 3 then
    problems[#problems + 1] = ("関数全体の選択(vaf)が動かない。選ばれた行: %d-%d"):format(first, last)
end

-- 4. まだ読み込まれていないプラグインもすべて読み込み、設定の誤りを表に出す
local ok, lazy = pcall(require, "lazy")
if ok then
    hook_notify()
    -- ほかのプラグインの依存としてだけ書かれたものは、単体では読み込まない。
    -- 親より先に読み込むと、実際には起きない順序のエラーが出るため(親を読み込めば一緒に読み込まれる)
    local names = {}
    for name, plugin in pairs(require("lazy.core.config").plugins) do
        if not plugin._.dep then
            names[#names + 1] = name
        end
    end
    table.sort(names)
    local loaded, err = pcall(lazy.load, { plugins = names })
    if not loaded then
        problems[#problems + 1] = tostring(err)
    end
    settle(3000)
end

-- 5. 出たメッセージからエラーを拾う
local messages = vim.api.nvim_exec2("messages", { output = true }).output
for line in messages:gmatch("[^\n]+") do
    if line:match("E%d+:") or line:match("Error") or line:match("Failed to") or line:match("stack traceback") then
        problems[#problems + 1] = messages
        break
    end
end

if #problems > 0 then
    io.stderr:write(table.concat(problems, "\n---\n") .. "\n")
    vim.cmd("cquit 1")
end
vim.cmd("qall!")
