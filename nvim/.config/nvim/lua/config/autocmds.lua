-- config/autocmds.lua

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- ─── Auto-detect external changes (e.g. from Claude Code) ───
local external_change = augroup("ExternalChange", { clear = true })

autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
    group = external_change,
    pattern = "*",
    callback = function()
        -- Inside cmdline mode or a command-line window (q:, q/), :checktime
        -- raises E11, so skip there.
        if vim.fn.mode() == "c" or vim.fn.getcmdwintype() ~= "" then
            return
        end
        vim.cmd("checktime")
    end,
    desc = "Auto-reload externally changed files",
})

autocmd("FileChangedShellPost", {
    group = external_change,
    pattern = "*",
    callback = function()
        vim.notify("File changed on disk. Reloaded.", vim.log.levels.WARN)
    end,
    desc = "Notify when reloaded",
})

-- ─── Restore the last edit position ───
autocmd("BufReadPost", {
    group = augroup("RestoreCursor", { clear = true }),
    callback = function()
        local mark = vim.api.nvim_buf_get_mark(0, '"')
        local lcount = vim.api.nvim_buf_line_count(0)
        if mark[1] > 0 and mark[1] <= lcount then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
    end,
    desc = "Restore last edit position",
})

-- ─── Trim trailing whitespace on save ───
autocmd("BufWritePre", {
    group = augroup("TrimWhitespace", { clear = true }),
    pattern = "*",
    command = [[%s/\s\+$//e]],
    desc = "Trim trailing whitespace on save",
})

-- ─── Terminal setup ───
autocmd("TermOpen", {
    group = augroup("TerminalSetup", { clear = true }),
    callback = function()
        vim.opt_local.number = false
        vim.opt_local.relativenumber = false
        vim.opt_local.signcolumn = "no"
        vim.cmd("startinsert")
    end,
    desc = "Hide line numbers + enter insert mode on TermOpen",
})

-- ─── Highlight on yank ───
autocmd("TextYankPost", {
    group = augroup("YankHighlight", { clear = true }),
    callback = function()
        vim.highlight.on_yank({ timeout = 200 })
    end,
    desc = "Highlight yanked region",
})
