-- plugins/comment.lua
-- gcc / gc / gbc 로 주석 토글. 언어별 주석 문법 자동 감지.
-- treesitter 가 있으면 embedded code 도 정확히 처리 (예: vim 안의 lua 블록).

return {
    "numToStr/Comment.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {},
    -- VSCode 스타일 Ctrl+/ — 일부 터미널은 <C-/>, 다른 일부는 <C-_> 로 보내므로 둘 다 매핑.
    keys = {
        { "<C-/>", "gcc", mode = "n", remap = true, desc = "주석 토글 (라인)" },
        { "<C-_>", "gcc", mode = "n", remap = true, desc = "주석 토글 (라인)" },
        { "<C-/>", "gc",  mode = "v", remap = true, desc = "주석 토글 (선택)" },
        { "<C-_>", "gc",  mode = "v", remap = true, desc = "주석 토글 (선택)" },
    },
}
