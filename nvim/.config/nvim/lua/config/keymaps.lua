-- config/keymaps.lua
-- Plugin-independent base keymaps.

local map = vim.keymap.set

-- ─── General ───
map("i", "jk", "<Esc>", { desc = "Esc" })
map("n", "<leader>w", "<cmd>w<cr>", { desc = "Save" })
map("n", "<leader>q", "<cmd>q<cr>", { desc = "Quit" })
map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })

-- ─── Window navigation (matches tmux pane navigation) ───
map("n", "<C-h>", "<C-w>h", { desc = "Left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Bottom window" })
map("n", "<C-k>", "<C-w>k", { desc = "Top window" })
map("n", "<C-l>", "<C-w>l", { desc = "Right window" })

-- ─── Window resize ───
map("n", "<C-Up>",    "<cmd>resize +2<cr>",          { desc = "Window height +" })
map("n", "<C-Down>",  "<cmd>resize -2<cr>",          { desc = "Window height -" })
map("n", "<C-Left>",  "<cmd>vertical resize -2<cr>", { desc = "Window width -" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Window width +" })

-- ─── Buffer cycle ───
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
map("n", "<S-l>", "<cmd>bnext<cr>",     { desc = "Next buffer" })

-- ─── Line move (visual mode) ───
map("v", "J", ":m '>+1<cr>gv=gv", { desc = "Move line down" })
map("v", "K", ":m '<-2<cr>gv=gv", { desc = "Move line up" })

-- ─── Keep selection after indent ───
map("v", "<", "<gv", { desc = "Outdent" })
map("v", ">", ">gv", { desc = "Indent" })

-- ─── Clipboard ───
map("x", "<leader>p", '"_dP', { desc = "Paste (preserve register)" })

-- Copy selection with a relative-path header (for pasting into Claude Code).
map("v", "<leader>yr", function()
    local start_line = vim.fn.line("'<")
    local end_line = vim.fn.line("'>")
    local filepath = vim.fn.expand("%:.")
    local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
    local header = string.format("# %s (L%d-%d)", filepath, start_line, end_line)
    local content = header .. "\n" .. table.concat(lines, "\n")
    vim.fn.setreg("+", content)
    vim.notify("Copied with path: " .. filepath, vim.log.levels.INFO)
end, { desc = "Copy path + code (for Claude)" })

-- ─── Diagnostics ───
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
