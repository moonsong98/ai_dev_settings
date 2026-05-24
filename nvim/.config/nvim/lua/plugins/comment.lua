-- plugins/comment.lua
-- gcc / gc / gbc 로 주석 토글. 언어별 주석 문법 자동 감지.
-- treesitter 가 있으면 embedded code 도 정확히 처리 (예: vim 안의 lua 블록).

return {
    "numToStr/Comment.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {},
}
