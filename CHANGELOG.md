# Changelog

모든 주요 변경사항을 이 파일에 기록합니다.
형식: [Keep a Changelog](https://keepachangelog.com/ko/1.1.0/)

## [2026-05-24] - tmux HUD · zsh · starship

### Added
- **tmux**:
  - `set -g mouse on` (마우스 스크롤/패인 선택)
  - iTerm 탭 타이틀: `set-titles on` + `set-titles-string "#S · #W"`
  - HUD 플러그인 추가: tmux-cpu, tmux-battery, tmux-prefix-highlight
  - 상태바에 git 브랜치 (inline), CPU/RAM/배터리/시간 표시
- **zsh**: 새 stow 패키지 (`zsh/`) — 기존 ~/.zshrc 이식, starship init 포함, cross-platform 가드 추가
- **starship**: 크로스 셸 프롬프트 (bash/zsh 동일 모양)
  - 설치 함수: macos/ubuntu/centos 스크립트에 모두 추가

### Fixed
- **tmux**: pane_current_command 이 Claude 버전("2.1.150" 등)으로 잡혀 윈도우 이름이 버전 숫자로 보이던 문제 → `automatic-rename-format` 정규식으로 "claude" 치환
- **tmux**: TPM 경로 통일 (`~/.tmux/plugins` → `~/.config/tmux/plugins`)

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
