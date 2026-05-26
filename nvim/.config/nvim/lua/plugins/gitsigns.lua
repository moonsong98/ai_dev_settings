-- plugins/gitsigns.lua
-- Shows git changes in the sign column + per-hunk navigation/actions.
-- Critical when Claude edits files: see exactly which lines changed, right where they changed.

return {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
        signs = {
            add          = { text = "▎" },
            change       = { text = "▎" },
            delete       = { text = "▁" },   -- lower one-eighth block — sits "below" the line
            topdelete    = { text = "▔" },   -- upper one-eighth block — sits "above" the line
            changedelete = { text = "▎" },
            untracked    = { text = "▎" },
        },
        on_attach = function(buffer)
            local gs = require("gitsigns")
            local function map(lhs, rhs, desc)
                vim.keymap.set("n", lhs, rhs, { buffer = buffer, desc = desc })
            end

            -- ─── Hunk navigation ───
            map("]h", function() gs.nav_hunk("next") end, "Next hunk")
            map("[h", function() gs.nav_hunk("prev") end, "Previous hunk")

            -- ─── View / compare ───
            map("<leader>hp", gs.preview_hunk, "Preview hunk (floating)")
            map("<leader>hd", gs.diffthis, "Diff (current vs HEAD)")
            map("<leader>hb", function() gs.blame_line({ full = true }) end, "Blame line (full)")
            map("<leader>tb", gs.toggle_current_line_blame, "Toggle inline blame")

            -- ─── stage / reset (same as git add / restore) ───
            map("<leader>hs", gs.stage_hunk, "Stage hunk")
            map("<leader>hr", gs.reset_hunk, "Reset hunk (revert change)")
            map("<leader>hS", gs.stage_buffer, "Stage entire buffer")
            map("<leader>hR", gs.reset_buffer, "Reset entire buffer")

            -- ─── Extras ───
            -- `ih` text object — use as vih / dih / yih / cih for hunk-scoped motions.
            vim.keymap.set({ "o", "x" }, "ih",
                "<cmd>Gitsigns select_hunk<cr>",
                { buffer = buffer, desc = "Hunk region (text object)" })
            -- Show deleted lines inline as grey virtual text — see what was removed.
            map("<leader>td", gs.toggle_deleted, "Toggle inline deleted-line view")
        end,
    },
}
