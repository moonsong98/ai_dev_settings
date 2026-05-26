-- plugins/comment.lua
-- Toggle comments via gcc / gc / gbc. Auto-detects per-language comment syntax.
-- With treesitter, embedded code is handled correctly (e.g. lua blocks inside vim files).

return {
    "numToStr/Comment.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {},
    -- VSCode-style Ctrl+/ — some terminals send <C-/>, others send <C-_>; map both.
    keys = {
        { "<C-/>", "gcc", mode = "n", remap = true, desc = "Toggle comment (line)" },
        { "<C-_>", "gcc", mode = "n", remap = true, desc = "Toggle comment (line)" },
        { "<C-/>", "gc",  mode = "v", remap = true, desc = "Toggle comment (selection)" },
        { "<C-_>", "gc",  mode = "v", remap = true, desc = "Toggle comment (selection)" },
    },
}
