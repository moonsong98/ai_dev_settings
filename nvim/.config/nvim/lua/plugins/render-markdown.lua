-- plugins/render-markdown.lua
-- Render markdown visually inside the nvim buffer.
--   # heading → larger text + color
--   **bold** → bold, *italic* → italic
--   `code` → boxed, ``` blocks → background + language label
--   tables, checkboxes, blockquotes, links — all decorated
-- Uses treesitter's markdown + markdown_inline parsers (already installed).

return {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
        "nvim-tree/nvim-web-devicons",
    },
    ft = { "markdown" },
    opts = {},
}
