# Changelog

모든 주요 변경사항을 이 파일에 기록합니다.
형식: [Keep a Changelog](https://keepachangelog.com/ko/1.1.0/)

## [2026-04-11] - 초기 설정

### Added
- **nvim**: lazy.nvim 기반 기본 구조 (플러그인 없이 순수 설정만)
  - 기본 옵션 (라인넘버, 탭, 검색 등)
  - 기본 키맵
  - lazy.nvim 부트스트랩
- **tmux**: 기본 설정
  - prefix: `C-a`
  - vi 모드 키바인딩
  - OS별 클립보드 연동
  - TPM (Tmux Plugin Manager) 부트스트랩
- **claude**: Claude Code 기본 설정
  - settings.json 템플릿
  - CLAUDE.md 프로젝트 인스트럭션 템플릿
- **scripts**: 크로스 플랫폼 설치 스크립트
  - macOS (Homebrew)
  - Ubuntu (apt)
  - CentOS 8 (dnf)
  - 이미 설치된 패키지 스킵 로직
- **docs**: 초기 문서
  - PACKAGES.md, KEYMAPS.md, TROUBLESHOOTING.md
