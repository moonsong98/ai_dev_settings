-- plugins/editor.lua
-- Minimal editor plugins.
-- Additional plugins go into their own files, one per file.

return {
    -- ─── Colorscheme ───
    {
        "folke/tokyonight.nvim",
        lazy = false,
        priority = 1000,
        opts = {
            style = "night",
            -- Clear backgrounds so iTerm transparency shows through nvim.
            transparent = true,
            styles = {
                sidebars = "transparent",   -- sidebars like oil
                floats   = "transparent",   -- floating windows: gitsigns preview, which-key, …
            },
            -- Override specific highlight groups after the colorscheme is applied
            -- (using colors from the tokyonight palette).
            on_highlights = function(hl, c)
                -- gitsigns: default tokyonight uses add=cyan / change=blue — low contrast.
                -- Unify on the git convention (green / yellow / red) for at-a-glance reading.
                hl.GitSignsAdd          = { fg = c.green }
                hl.GitSignsChange       = { fg = c.yellow }
                hl.GitSignsDelete       = { fg = c.red }
                hl.GitSignsTopdelete    = { fg = c.red }
                hl.GitSignsChangedelete = { fg = c.yellow }
                hl.GitSignsUntracked    = { fg = c.green }
            end,
        },
        config = function(_, opts)
            require("tokyonight").setup(opts)
            vim.cmd.colorscheme("tokyonight")
        end,
    },

    -- ─── which-key (keymap helper popup) ───
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        opts = {},
    },
}
