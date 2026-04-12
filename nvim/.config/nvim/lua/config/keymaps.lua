-- config/keymaps.lua
-- 플러그인에 의존하지 않는 기본 키맵

local map = vim.keymap.set

-- ─── 일반 ───
map("i", "jk", "<Esc>", { desc = "Esc" })
map("n", "<leader>w", "<cmd>w<cr>", { desc = "저장" })
map("n", "<leader>q", "<cmd>q<cr>", { desc = "닫기" })
map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "하이라이트 해제" })

-- ─── 창 이동 (tmux와 통일) ───
map("n", "<C-h>", "<C-w>h", { desc = "왼쪽 창" })
map("n", "<C-j>", "<C-w>j", { desc = "아래 창" })
map("n", "<C-k>", "<C-w>k", { desc = "위 창" })
map("n", "<C-l>", "<C-w>l", { desc = "오른쪽 창" })

-- ─── 창 크기 조절 ───
map("n", "<C-Up>",    "<cmd>resize +2<cr>",          { desc = "창 높이 +" })
map("n", "<C-Down>",  "<cmd>resize -2<cr>",          { desc = "창 높이 -" })
map("n", "<C-Left>",  "<cmd>vertical resize -2<cr>", { desc = "창 너비 -" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "창 너비 +" })

-- ─── 버퍼 이동 ───
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "이전 버퍼" })
map("n", "<S-l>", "<cmd>bnext<cr>",     { desc = "다음 버퍼" })

-- ─── 라인 이동 (Visual 모드) ───
map("v", "J", ":m '>+1<cr>gv=gv", { desc = "라인 아래로" })
map("v", "K", ":m '<-2<cr>gv=gv", { desc = "라인 위로" })

-- ─── 들여쓰기 유지 ───
map("v", "<", "<gv", { desc = "내어쓰기" })
map("v", ">", ">gv", { desc = "들여쓰기" })

-- ─── 클립보드 ───
map("x", "<leader>p", '"_dP', { desc = "붙여넣기 (레지스터 보존)" })

-- 상대경로 + 코드 복사 (Claude Code용)
map("v", "<leader>yr", function()
    local start_line = vim.fn.line("'<")
    local end_line = vim.fn.line("'>")
    local filepath = vim.fn.expand("%:.")
    local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
    local header = string.format("# %s (L%d-%d)", filepath, start_line, end_line)
    local content = header .. "\n" .. table.concat(lines, "\n")
    vim.fn.setreg("+", content)
    vim.notify("Copied with path: " .. filepath, vim.log.levels.INFO)
end, { desc = "경로+코드 복사 (Claude용)" })

-- ─── 진단 ───
map("n", "[d", vim.diagnostic.goto_prev, { desc = "이전 진단" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "다음 진단" })
