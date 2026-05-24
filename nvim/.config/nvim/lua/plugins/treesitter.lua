-- plugins/treesitter.lua
-- 언어별 AST 파서 기반 정밀 하이라이트 + 인덴트.
-- 빌드 시 :TSUpdate 가 자동 호출돼 ensure_installed 의 parser 들을 컴파일 (gcc/clang 필요).

return {
    "nvim-treesitter/nvim-treesitter",
    -- `main` 브랜치는 새 rewrite 중이라 API 가 다름 (configs 모듈 없음).
    -- legacy 안정판인 master 브랜치 사용.
    branch = "master",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
        ensure_installed = {
            -- 코어 (nvim 자체용)
            "lua", "vim", "vimdoc", "query", "regex",
            -- 자주 쓰는 언어
            "bash", "python", "javascript", "typescript", "tsx",
            -- 데이터 / 설정 포맷
            "json", "yaml", "toml",
            -- 마크업
            "markdown", "markdown_inline", "html", "css",
            -- git 관련
            "gitcommit", "gitignore", "diff",
            -- 기타
            "dockerfile", "sql",
        },
        -- 새 버퍼에서 parser 가 없으면 자동 설치 (background)
        auto_install = true,
        highlight = {
            enable = true,
            -- 일부 큰 파일에서 성능 보호: 100KB 이상이면 treesitter 끔
            disable = function(_, buf)
                local max_filesize = 100 * 1024
                local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
                if ok and stats and stats.size > max_filesize then
                    return true
                end
            end,
        },
        indent = { enable = true },
    },
    config = function(_, opts)
        require("nvim-treesitter.configs").setup(opts)
    end,
}
