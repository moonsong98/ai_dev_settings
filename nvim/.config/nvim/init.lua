-- ╔══════════════════════════════════════════╗
-- ║  Neovim Configuration                    ║
-- ║  lazy.nvim 기반 · 크로스 플랫폼          ║
-- ╚══════════════════════════════════════════╝

-- 기본 옵션 (플러그인 로드 전)
require("config.options")

-- 기본 키맵 (플러그인 무관)
require("config.keymaps")

-- Autocmd
require("config.autocmds")

-- lazy.nvim 부트스트랩 & 플러그인 로드
require("config.lazy")
