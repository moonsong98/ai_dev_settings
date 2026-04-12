# Packages

현재 사용 중인 패키지 목록과 역할.
변경 시 반드시 CHANGELOG.md 도 함께 업데이트할 것.

## 시스템 패키지

| 패키지 | 최소 버전 | 테스트 버전 | 역할 | 비고 |
|---|---|---|---|---|
| neovim | 0.10.0 | 0.11.x | 에디터 | appimage (CentOS) |
| tmux | 3.2 | 3.5a | 터미널 멀티플렉서 | |
| node | 18.x | 22.x LTS | Claude Code 런타임 | |
| git | 2.x | 2.45 | 버전 관리 | |
| stow | 2.x | 2.4.0 | 심링크 관리 | |
| ripgrep | 13.x | 14.x | 검색 (grep 대체) | |
| fd | 8.x | 10.x | 파일 찾기 (find 대체) | |
| fzf | 0.40+ | 0.57 | 퍼지 파인더 | |

## Neovim 플러그인 (lazy.nvim)

| 플러그인 | 역할 | lazy? | 비고 |
|---|---|---|---|
| folke/lazy.nvim | 플러그인 매니저 | - | 부트스트랩 |
| folke/tokyonight.nvim | 컬러스킴 | No | priority=1000 |
| folke/which-key.nvim | 키맵 도움말 | Yes | VeryLazy |

> 플러그인 정확한 버전은 `nvim/lazy-lock.json` 에서 관리됩니다.

## tmux 플러그인 (TPM)

| 플러그인 | 역할 | 비고 |
|---|---|---|
| tmux-plugins/tpm | 플러그인 매니저 | |
| tmux-plugins/tmux-sensible | 합리적 기본값 | |
| tmux-plugins/tmux-resurrect | 세션 저장/복원 | prefix + C-s / C-r |

## npm 글로벌 패키지

| 패키지 | 역할 |
|---|---|
| @anthropic-ai/claude-code | Claude Code CLI |

## 패키지 추가 절차

1. 이 문서에 패키지 정보 추가
2. 해당 OS 설치 스크립트에 설치 함수 추가
3. CHANGELOG.md 에 기록
4. 테스트: 3개 OS에서 `./install.sh` 실행 확인
