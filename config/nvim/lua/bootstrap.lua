-- lazy.nvim(プラグイン管理)自身を、まだなければ取得する。
-- ターミナル用の設定(lazyvim.lua)と Cursor 用の設定(vscode-config.lua)の両方から読み込む。
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    -- stylua: ignore
    vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", lazypath })
    -- lazy.nvim 自身の版を lazy-lock.json に合わせる。
    -- 合わせないと、新しいマシンでの初回の起動で lazy-lock.json が書き換わり、マシンごとに版がずれる
    local ok, lock = pcall(function()
        return vim.json.decode(table.concat(vim.fn.readfile(vim.fn.stdpath("config") .. "/lazy-lock.json"), "\n"))
    end)
    if ok and lock["lazy.nvim"] then
        vim.fn.system({ "git", "-C", lazypath, "checkout", lock["lazy.nvim"].commit })
    end
end
vim.opt.rtp:prepend(vim.env.LAZY or lazypath)
