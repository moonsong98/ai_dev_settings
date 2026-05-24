-- plugins/render-markdown.lua
-- markdown 버퍼를 nvim 안에서 시각적으로 렌더링.
--   # 헤더 → 큰 글씨 + 컬러
--   **bold** → 굵게,  *italic* → 기울임
--   `code` → 박스, ``` 블록 → 배경 + 언어 라벨
--   표, 체크박스, 인용, 링크 시각화
-- treesitter 의 markdown + markdown_inline parser 사용 (이미 설치됨).

return {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
        "nvim-tree/nvim-web-devicons",
    },
    ft = { "markdown" },
    opts = {},
}
