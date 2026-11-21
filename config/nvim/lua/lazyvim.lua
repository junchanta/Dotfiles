require("bootstrap")

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
