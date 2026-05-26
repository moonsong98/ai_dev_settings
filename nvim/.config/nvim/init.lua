-- ╔══════════════════════════════════════════╗
-- ║  Neovim Configuration                    ║
-- ║  lazy.nvim-based · cross-platform        ║
-- ╚══════════════════════════════════════════╝

-- Basic options (must run before plugin load)
require("config.options")

-- Plugin-independent keymaps
require("config.keymaps")

-- Autocmds
require("config.autocmds")

-- lazy.nvim bootstrap & plugin load
require("config.lazy")
