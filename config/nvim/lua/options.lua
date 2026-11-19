-- =============================================================================
-- Options Configuration
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Encoding & Files
-- -----------------------------------------------------------------------------
vim.opt.encoding = "utf-8"
vim.opt.backup = false
vim.opt.swapfile = false
vim.opt.autoread = true
vim.opt.hidden = true

-- -----------------------------------------------------------------------------
-- Clipboard
-- -----------------------------------------------------------------------------
vim.opt.clipboard = "unnamedplus"

-- -----------------------------------------------------------------------------
-- Indentation
-- -----------------------------------------------------------------------------
vim.opt.smartindent = true
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.autoindent = true

-- -----------------------------------------------------------------------------
-- Display
-- -----------------------------------------------------------------------------
vim.opt.termguicolors = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.showcmd = true
vim.opt.virtualedit = "onemore"
vim.opt.visualbell = true
vim.opt.showmatch = true
vim.opt.laststatus = 2  -- 各ウィンドウにステータスライン
vim.opt.wildmode = "list:longest"

-- -----------------------------------------------------------------------------
-- Window
-- -----------------------------------------------------------------------------
-- ウィンドウ境界線を太い線に
vim.opt.fillchars = {
    vert = "│",
    horiz = "─",
    horizup = "┴",
    horizdown = "┬",
    vertleft = "┤",
    vertright = "├",
    verthoriz = "┼",
}
-- winbar は lualine で管理（statusline.lua）

-- -----------------------------------------------------------------------------
-- Search
-- -----------------------------------------------------------------------------
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.incsearch = true
vim.opt.wrapscan = true
vim.opt.hlsearch = true

-- -----------------------------------------------------------------------------
-- Mouse
-- -----------------------------------------------------------------------------
vim.opt.mouse = "a"

-- NOTE: カスタムハイライト設定は ui/colorscheme.lua に移動済み
