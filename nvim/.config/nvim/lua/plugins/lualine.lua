-- plugins/lualine.lua
-- Rich statusline. globalstatus=true → single line at the bottom of the screen
-- instead of one per window.

return {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy",
    opts = {
        options = {
            theme = "tokyonight",
            globalstatus = true,
            section_separators = "",   -- no powerline arrows (cleaner)
            component_separators = "│",
        },
        sections = {
            lualine_a = { "mode" },
            lualine_b = { "branch", "diff", "diagnostics" },
            lualine_c = {
                { "filename", path = 1 },   -- relative path from cwd
            },
            lualine_x = { "encoding", "filetype" },
            lualine_y = { "progress" },
            lualine_z = { "location" },
        },
    },
}
