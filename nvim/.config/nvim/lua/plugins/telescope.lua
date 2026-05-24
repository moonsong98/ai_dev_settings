-- plugins/telescope.lua
-- fzf 스타일 퍼지 파인더 + 다양한 picker (파일/내용/버퍼/git/...).
-- fzf-native 확장은 C 로 빌드돼 큰 결과 셋에서 체감 차이.

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
        -- 파일 / 내용
        { "<leader>ff", "<cmd>Telescope find_files<cr>",   desc = "파일 찾기" },
        { "<leader>fg", "<cmd>Telescope live_grep<cr>",    desc = "내용 검색 (live grep)" },
        { "<leader>fs", "<cmd>Telescope grep_string<cr>",  desc = "커서 단어 grep" },
        { "<leader>fr", "<cmd>Telescope oldfiles<cr>",     desc = "최근 연 파일" },
        -- 버퍼 / 도움말
        { "<leader>fb", "<cmd>Telescope buffers<cr>",      desc = "열린 버퍼 전환" },
        { "<leader>fh", "<cmd>Telescope help_tags<cr>",    desc = "vim help 검색" },
        { "<leader>fk", "<cmd>Telescope keymaps<cr>",      desc = "키맵 검색" },
        { "<leader>fc", "<cmd>Telescope commands<cr>",     desc = "명령어 검색" },
        -- git
        { "<leader>gb", "<cmd>Telescope git_branches<cr>", desc = "git 브랜치" },
        { "<leader>gs", "<cmd>Telescope git_status<cr>",   desc = "git 변경 파일" },
        { "<leader>gc", "<cmd>Telescope git_commits<cr>",  desc = "git 커밋 로그" },
        -- 재실행: 직전 picker 다시 열기
        { "<leader>f.", "<cmd>Telescope resume<cr>",       desc = "직전 picker 재실행" },
    },
    opts = {
        defaults = {
            -- live_grep 가 쓰는 ripgrep 인자: hidden 포함, .git/ 만 제외
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
                -- fd 가 ripgrep 보다 파일 열거에 더 빠름
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
