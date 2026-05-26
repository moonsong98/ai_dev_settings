-- plugins/oil.lua
-- File explorer that opens a directory as a buffer you edit with vim motions.
--   `:w`   save changes (rename, delete, create)
--   `-`    go up one directory (when already in oil)
--   `<CR>` open file / descend into directory
--   `q`    close

return {
    "stevearc/oil.nvim",
    -- Disable lazy loading so oil takes over when nvim is launched on a directory.
    lazy = false,
    opts = {
        default_file_explorer = true,
        view_options = {
            show_hidden = true,
        },
        -- Reserve room for the two-char status code (index + worktree) drawn by oil-git-status.
        win_options = {
            signcolumn = "yes:2",
        },
        keymaps = {
            -- Disable oil's <C-h/j/k/l> so they don't collide with our window-nav maps.
            ["<C-h>"] = false,
            ["<C-j>"] = false,
            ["<C-k>"] = false,
            ["<C-l>"] = false,
            -- Use the vim convention of `q` to close (default is <C-c>).
            ["q"] = "actions.close",
        },
    },
    keys = {
        { "-",         "<cmd>Oil<cr>", desc = "File explorer (oil)" },
        { "<leader>e", "<cmd>Oil<cr>", desc = "File explorer (oil)" },
    },
}
