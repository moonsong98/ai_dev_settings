-- plugins/oil-git-status.lua
-- oil 버퍼에 git status 컬럼 두 개 추가 (index/staged + working tree).
-- 예: "  M" = 워킹트리에서 수정 (unstaged), "M " = staged, "??" = untracked

return {
    "refractalize/oil-git-status.nvim",
    dependencies = { "stevearc/oil.nvim" },
    -- oil 이 열릴 때 같이 로드되면 됨
    event = "User OilEnter",
    config = true,
}
