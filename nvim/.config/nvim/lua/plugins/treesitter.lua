-- plugins/treesitter.lua
-- nvim-treesitter `main` branch (master is archived and incompatible with nvim 0.12's new API).
-- The main branch is library-shaped: call install() to add parsers, and start
-- highlighting yourself via vim.treesitter.start() on FileType.

return {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
        local ts = require("nvim-treesitter")
        local want = {
            -- core
            "lua", "vim", "vimdoc", "query", "regex",
            -- common languages
            "bash", "python", "javascript", "typescript", "tsx",
            -- data / config
            "json", "yaml", "toml",
            -- markup
            "markdown", "markdown_inline", "html", "css",
            -- git
            "gitcommit", "gitignore", "diff",
            -- misc
            "dockerfile", "sql",
        }
        -- Only call install() for the parsers we don't already have — avoids
        -- the per-startup overhead of re-downloading bundled items like
        -- vim/gitcommit that get reported as "not installed".
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

        -- If the buffer's filetype has a matching parser, enable treesitter
        -- highlighting. The main branch has no module system, so we wire it up
        -- explicitly here.
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
