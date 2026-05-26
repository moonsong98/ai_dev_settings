-- plugins/oil-git-status.lua
-- Adds two git-status columns to the oil buffer (index/staged + working tree).
-- Examples: "  M" = modified in worktree (unstaged), "M " = staged, "??" = untracked.

return {
    "refractalize/oil-git-status.nvim",
    dependencies = { "stevearc/oil.nvim" },
    -- Load alongside oil when it opens.
    event = "User OilEnter",
    config = true,
}
