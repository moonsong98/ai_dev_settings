-- config/autocmds.lua

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- ─── 외부 변경 자동 감지 (Claude Code 등) ───
local external_change = augroup("ExternalChange", { clear = true })

autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
    group = external_change,
    pattern = "*",
    callback = function()
        -- cmdline 모드 또는 command-line window (q:, q/) 안에서는 :checktime 이 E11 발생 → skip
        if vim.fn.mode() == "c" or vim.fn.getcmdwintype() ~= "" then
            return
        end
        vim.cmd("checktime")
    end,
    desc = "외부 파일 변경 자동 리로드",
})

autocmd("FileChangedShellPost", {
    group = external_change,
    pattern = "*",
    callback = function()
        vim.notify("File changed on disk. Reloaded.", vim.log.levels.WARN)
    end,
    desc = "리로드 알림",
})

-- ─── 마지막 편집 위치 복원 ───
autocmd("BufReadPost", {
    group = augroup("RestoreCursor", { clear = true }),
    callback = function()
        local mark = vim.api.nvim_buf_get_mark(0, '"')
        local lcount = vim.api.nvim_buf_line_count(0)
        if mark[1] > 0 and mark[1] <= lcount then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
    end,
    desc = "마지막 편집 위치 복원",
})

-- ─── 저장 시 후행 공백 제거 ───
autocmd("BufWritePre", {
    group = augroup("TrimWhitespace", { clear = true }),
    pattern = "*",
    command = [[%s/\s\+$//e]],
    desc = "저장 시 후행 공백 제거",
})

-- ─── 터미널 설정 ───
autocmd("TermOpen", {
    group = augroup("TerminalSetup", { clear = true }),
    callback = function()
        vim.opt_local.number = false
        vim.opt_local.relativenumber = false
        vim.opt_local.signcolumn = "no"
        vim.cmd("startinsert")
    end,
    desc = "터미널 열 때 라인넘버 숨김 + insert 모드",
})

-- ─── yank 하이라이트 ───
autocmd("TextYankPost", {
    group = augroup("YankHighlight", { clear = true }),
    callback = function()
        vim.highlight.on_yank({ timeout = 200 })
    end,
    desc = "복사 시 하이라이트",
})
