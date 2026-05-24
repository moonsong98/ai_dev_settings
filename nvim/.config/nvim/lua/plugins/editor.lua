-- plugins/editor.lua
-- 최소한의 에디터 플러그인
-- 추가 플러그인은 별도 파일로 하나씩 추가

return {
    -- ─── 컬러스킴 ───
    {
        "folke/tokyonight.nvim",
        lazy = false,
        priority = 1000,
        opts = {
            style = "night",
            -- iTerm transparency 가 nvim 까지 비치도록 Normal 등의 bg 를 비움
            transparent = true,
            styles = {
                sidebars = "transparent",   -- oil 등 사이드바
                floats   = "transparent",   -- gitsigns preview, which-key 등 floating
            },
            -- 컬러스킴 적용 직후 일부 그룹 색 override (tokyonight 팔레트 안의 색 사용)
            on_highlights = function(hl, c)
                -- gitsigns: tokyonight 기본은 add=청록 / change=파랑 으로 대비 약함.
                -- git 컨벤션 (녹/노/빨) 로 통일해서 한 눈에 구분되게.
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

    -- ─── which-key (키맵 도움말) ───
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        opts = {},
    },
}
