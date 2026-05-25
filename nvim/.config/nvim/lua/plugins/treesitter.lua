-- plugins/treesitter.lua
-- nvim-treesitter `main` 브랜치 (master 는 archived + nvim 0.12 의 새 API 와 호환 X).
-- main 은 라이브러리 형태 — install() 로 parser 설치하고, highlight 은 직접
-- vim.treesitter.start() 를 FileType 시점에 호출.

return {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
        local ts = require("nvim-treesitter")
        local want = {
            -- 코어
            "lua", "vim", "vimdoc", "query", "regex",
            -- 자주 쓰는 언어
            "bash", "python", "javascript", "typescript", "tsx",
            -- 데이터 / 설정
            "json", "yaml", "toml",
            -- 마크업
            "markdown", "markdown_inline", "html", "css",
            -- git
            "gitcommit", "gitignore", "diff",
            -- 기타
            "dockerfile", "sql",
        }
        -- 이미 설치된 parser 는 빼고 install() 호출 — 매 startup 마다
        -- vim/gitcommit 같은 미탐지 항목 재다운로드 시도하던 부담 제거
        local installed = {}
        for _, lang in ipairs(ts.get_installed("parsers") or {}) do
            installed[lang] = true
        end
        local missing = {}
        for _, lang in ipairs(want) do
            if not installed[lang] then
                table.insert(missing, lang)
            end
        end
        if #missing > 0 then
            ts.install(missing)
        end

        -- 버퍼의 filetype 에 매칭되는 parser 가 있으면 treesitter 하이라이트 켬.
        -- main 브랜치는 module 시스템이 없어서 사용자가 명시적으로 켜야 함.
        vim.api.nvim_create_autocmd("FileType", {
            callback = function(args)
                local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
                if lang then
                    pcall(vim.treesitter.start, args.buf, lang)
                end
            end,
        })
    end,
}
