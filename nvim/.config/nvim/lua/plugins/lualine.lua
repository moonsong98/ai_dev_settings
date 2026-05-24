-- plugins/lualine.lua
-- 풍성한 statusline. globalstatus=true 로 윈도우 별이 아닌 화면 맨 아래 한 줄.

return {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy",
    opts = {
        options = {
            theme = "tokyonight",
            globalstatus = true,
            section_separators = "",   -- powerline 화살표 안 씀 (간결)
            component_separators = "│",
        },
        sections = {
            lualine_a = { "mode" },
            lualine_b = { "branch", "diff", "diagnostics" },
            lualine_c = {
                { "filename", path = 1 },   -- cwd 기준 상대경로
            },
            lualine_x = { "encoding", "filetype" },
            lualine_y = { "progress" },
            lualine_z = { "location" },
        },
    },
}
