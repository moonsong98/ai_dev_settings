-- plugins/surround.lua
-- 괄호/따옴표/태그 등 surrounding 조작.
--   cs"'   "x" → 'x'
--   ds"    "x" → x
--   ysiw)  word → (word)
--   yss"   라인 전체를 "..." 로
--   S"     visual 선택 영역을 "..." 로

return {
    "kylechui/nvim-surround",
    version = "*",   -- 안정판 태그 사용
    event = { "BufReadPost", "BufNewFile" },
    opts = {},
}
