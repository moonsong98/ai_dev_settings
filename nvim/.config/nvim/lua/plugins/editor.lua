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
