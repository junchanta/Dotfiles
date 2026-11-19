-- =============================================================================
-- Neovim Configuration Entry Point
-- =============================================================================

-- Load options (must be first)
require("options")

-- Load keymaps (Leader Key must be set before lazy.nvim)
require("keymaps")

-- VSCode/Cursor or Neovim mode
if vim.g.vscode then
    require("vscode-config")
else
    require("lazyvim")
end
