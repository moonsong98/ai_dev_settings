-- plugins/surround.lua
-- Edit surrounding brackets / quotes / tags.
--   cs"'   "x" → 'x'
--   ds"    "x" → x
--   ysiw)  word → (word)
--   yss"   wrap the whole line in "..."
--   S"     wrap the visual selection in "..."

return {
    "kylechui/nvim-surround",
    version = "*",   -- use the stable tag
    event = { "BufReadPost", "BufNewFile" },
    opts = {},
}
