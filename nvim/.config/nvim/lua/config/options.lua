-- config/options.lua
-- 에디터 기본 옵션

local opt = vim.opt

-- ─── 라인 넘버 ───
opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes"

-- ─── 들여쓰기 ───
opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 4
opt.expandtab = true
opt.smartindent = true

-- ─── 검색 ───
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true

-- ─── UI ───
opt.termguicolors = true
opt.cursorline = true
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.wrap = false
opt.showmode = false
opt.splitbelow = true
opt.splitright = true
opt.mouse = "a"

-- ─── 파일 ───
opt.swapfile = false
opt.backup = false
opt.undofile = true
opt.undodir = vim.fn.stdpath("state") .. "/undo"
opt.fileencoding = "utf-8"

-- ─── 자동 리로드 (Claude Code 등 외부 변경 감지) ───
opt.autoread = true
opt.updatetime = 250

-- ─── 완성 ───
opt.completeopt = { "menu", "menuone", "noselect" }

-- ─── 클립보드 (OS별 자동 감지) ───
if vim.fn.has("mac") == 1 then
    opt.clipboard = "unnamedplus"
elseif vim.fn.has("wsl") == 1 then
    vim.g.clipboard = {
        name = "win32yank",
        copy = {
            ["+"] = "win32yank.exe -i --crlf",
            ["*"] = "win32yank.exe -i --crlf",
        },
        paste = {
            ["+"] = "win32yank.exe -o --lf",
            ["*"] = "win32yank.exe -o --lf",
        },
        cache_enabled = false,
    }
else
    opt.clipboard = "unnamedplus"
end

-- ─── Leader 키 ───
vim.g.mapleader = " "
vim.g.maplocalleader = " "
