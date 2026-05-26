-- plugins/telescope.lua
-- fzf-style fuzzy finder + assorted pickers (files / content / buffers / git / …).
-- fzf-native is built in C and is noticeably faster on large result sets.

return {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    dependencies = {
        "nvim-lua/plenary.nvim",
        {
            "nvim-telescope/telescope-fzf-native.nvim",
            build = "make",
        },
    },
    keys = {
        -- Files / content
        { "<leader>ff", "<cmd>Telescope find_files<cr>",   desc = "Find file" },
        { "<leader>fg", "<cmd>Telescope live_grep<cr>",    desc = "Live grep (content)" },
        { "<leader>fs", "<cmd>Telescope grep_string<cr>",  desc = "Grep word under cursor" },
        { "<leader>fr", "<cmd>Telescope oldfiles<cr>",     desc = "Recently opened files" },
        -- Buffers / help
        { "<leader>fb", "<cmd>Telescope buffers<cr>",      desc = "Switch buffer" },
        { "<leader>fh", "<cmd>Telescope help_tags<cr>",    desc = "Search vim help" },
        { "<leader>fk", "<cmd>Telescope keymaps<cr>",      desc = "Search keymaps" },
        { "<leader>fc", "<cmd>Telescope commands<cr>",     desc = "Search commands" },
        -- git
        { "<leader>gb", "<cmd>Telescope git_branches<cr>", desc = "git branches" },
        { "<leader>gs", "<cmd>Telescope git_status<cr>",   desc = "git modified files" },
        { "<leader>gc", "<cmd>Telescope git_commits<cr>",  desc = "git commit log" },
        -- Resume: re-open the last picker
        { "<leader>f.", "<cmd>Telescope resume<cr>",       desc = "Resume last picker" },
    },
    opts = {
        defaults = {
            -- ripgrep args used by live_grep: include hidden, only exclude .git/
            vimgrep_arguments = {
                "rg",
                "--color=never",
                "--no-heading",
                "--with-filename",
                "--line-number",
                "--column",
                "--smart-case",
                "--hidden",
                "--glob=!.git/",
            },
            path_display = { "smart" },
        },
        pickers = {
            find_files = {
                hidden = true,
                -- fd is faster than ripgrep for plain file enumeration.
                find_command = { "fd", "--type=f", "--hidden", "--exclude=.git" },
            },
            buffers = {
                sort_lastused = true,
                sort_mru = true,
            },
        },
        extensions = {
            fzf = {
                fuzzy = true,
                override_generic_sorter = true,
                override_file_sorter = true,
                case_mode = "smart_case",
            },
        },
    },
    config = function(_, opts)
        local telescope = require("telescope")
        telescope.setup(opts)
        pcall(telescope.load_extension, "fzf")
    end,
}
