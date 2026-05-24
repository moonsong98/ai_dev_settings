-- plugins/gitsigns.lua
-- 사인 컬럼에 git 변경 사항 표시 + hunk 단위 탐색/조작.
-- Claude 가 파일을 수정했을 때 어떤 라인이 어떻게 바뀌었는지 그 자리에서 확인하기 위한 핵심.

return {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
        signs = {
            add          = { text = "▎" },
            change       = { text = "▎" },
            delete       = { text = "▁" },   -- lower one-eighth block — 라인 아래에 그려진 듯한 느낌
            topdelete    = { text = "▔" },   -- upper one-eighth block — 라인 위
            changedelete = { text = "▎" },
            untracked    = { text = "▎" },
        },
        on_attach = function(buffer)
            local gs = require("gitsigns")
            local function map(lhs, rhs, desc)
                vim.keymap.set("n", lhs, rhs, { buffer = buffer, desc = desc })
            end

            -- ─── 변경 hunk 탐색 ───
            map("]h", function() gs.nav_hunk("next") end, "다음 변경")
            map("[h", function() gs.nav_hunk("prev") end, "이전 변경")

            -- ─── 변경 보기 / 비교 ───
            map("<leader>hp", gs.preview_hunk, "변경 미리보기 (floating)")
            map("<leader>hd", gs.diffthis, "diff 보기 (현재 vs HEAD)")
            map("<leader>hb", function() gs.blame_line({ full = true }) end, "라인 blame (전체)")
            map("<leader>tb", gs.toggle_current_line_blame, "라인 blame 토글 (인라인)")

            -- ─── stage / reset (git add / restore 와 같음) ───
            map("<leader>hs", gs.stage_hunk, "stage hunk")
            map("<leader>hr", gs.reset_hunk, "reset hunk (변경 되돌리기)")
            map("<leader>hS", gs.stage_buffer, "버퍼 전체 stage")
            map("<leader>hR", gs.reset_buffer, "버퍼 전체 reset")

            -- ─── 추가 ───
            -- ih 텍스트 오브젝트: vih, dih, yih, cih 처럼 hunk 단위 모션
            vim.keymap.set({ "o", "x" }, "ih",
                "<cmd>Gitsigns select_hunk<cr>",
                { buffer = buffer, desc = "hunk 영역 (텍스트 오브젝트)" })
            -- 삭제된 라인을 인라인 회색 텍스트로 보여줌 — 무엇이 지워졌는지 확인용
            map("<leader>td", gs.toggle_deleted, "삭제된 라인 인라인 토글")
        end,
    },
}
