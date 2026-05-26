-- config/options.lua
-- Editor default options.

local opt = vim.opt

-- ─── Line numbers ───
opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes"

-- ─── Indentation ───
opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 4
opt.expandtab = true
opt.smartindent = true

-- ─── Search ───
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
-- Replace the E37 "no write since last change" error with a "Save? Y/n/c" prompt.
opt.confirm = true

-- ─── Files ───
opt.swapfile = false
opt.backup = false
opt.undofile = true
opt.undodir = vim.fn.stdpath("state") .. "/undo"
opt.fileencoding = "utf-8"

-- ─── Auto-reload (catch external changes from Claude Code, etc.) ───
opt.autoread = true
opt.updatetime = 250

-- ─── Completion ───
opt.completeopt = { "menu", "menuone", "noselect" }

-- ─── Clipboard (auto-detect per OS) ───
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

-- ─── Leader key ───
vim.g.mapleader = " "
vim.g.maplocalleader = " "
