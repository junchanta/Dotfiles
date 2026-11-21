local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  -- bootstrap lazy.nvim
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

require("lazy").setup({
  spec = {
    -- import plugins by category
    { import = "plugins.core" },       -- treesitter, lsp, coding, diagnostic
    { import = "plugins.ui" },         -- colorscheme, statusline
    { import = "plugins.navigation" }, -- filer, telescope
    { import = "plugins.tools" },      -- git, terminal, ai, markdown, memo, debugger
    { import = "plugins.lang" },       -- python, typescript
  },
  defaults = {
    -- Enable lazy loading by default for better startup performance
    lazy = true,
    -- It's recommended to leave version=false for now, since a lot the plugin that support versioning,
    -- have outdated releases, which may break your Neovim install.
    version = false, -- always use the latest git commit
    -- version = "*", -- try installing the latest stable version for plugins that support semver
  },
  install = { colorscheme = { "tokyonight", "habamax" } },
  checker = { enabled = true }, -- automatically check for plugin updates
  performance = {
    rtp = {
      -- disable some rtp plugins
      disabled_plugins = {
        "gzip",
        -- "matchit",
        -- "matchparen",
        -- "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
