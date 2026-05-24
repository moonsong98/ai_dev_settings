-- plugins/oil.lua
-- 디렉토리를 버퍼로 열어 vim 모션으로 편집하는 파일 탐색기.
--   `:w`  변경 저장 (rename, delete, create)
--   `-`   상위 디렉토리로 (oil 안에서)
--   `<CR>` 파일 열기 / 디렉토리 진입
--   `q`   닫기

return {
    "stevearc/oil.nvim",
    -- 디렉토리로 nvim 을 띄울 때 oil 이 즉시 받게 lazy 해제
    lazy = false,
    opts = {
        default_file_explorer = true,
        view_options = {
            show_hidden = true,
        },
        -- oil-git-status 가 두 글자 status code (index + worktree) 를 그릴 자리 확보
        win_options = {
            signcolumn = "yes:2",
        },
        keymaps = {
            -- 우리 `<C-h/j/k/l>` 윈도우 이동과 안 겹치게 oil 내 충돌 키 비활성
            ["<C-h>"] = false,
            ["<C-j>"] = false,
            ["<C-k>"] = false,
            ["<C-l>"] = false,
            -- vim 관습대로 q 로 닫기 (기본은 <C-c>)
            ["q"] = "actions.close",
        },
    },
    keys = {
        { "-",         "<cmd>Oil<cr>", desc = "파일 탐색기 (oil)" },
        { "<leader>e", "<cmd>Oil<cr>", desc = "파일 탐색기 (oil)" },
    },
}
