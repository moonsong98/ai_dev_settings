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
| starship | 1.x | 1.25 | 크로스 셸 프롬프트 | Linux 는 install.sh (no apt/dnf) |

## Neovim 플러그인 (lazy.nvim)

| 플러그인 | 역할 | lazy? | 비고 |
|---|---|---|---|
| folke/lazy.nvim | 플러그인 매니저 | - | 부트스트랩 |
| folke/tokyonight.nvim | 컬러스킴 | No | priority=1000 |
| folke/which-key.nvim | 키맵 도움말 | Yes | VeryLazy |
| stevearc/oil.nvim | 파일 탐색기 (디렉토리를 버퍼로) | No | `-` / `<leader>e` |
| refractalize/oil-git-status.nvim | oil 안에서 git status 컬럼 | Yes | User OilEnter |
| lewis6991/gitsigns.nvim | 사인 컬럼에 git diff + hunk 조작 | Yes | BufReadPre 시 로드 |
| nvim-telescope/telescope.nvim | 퍼지 파인더 (파일/grep/buffer/git/...) | Yes | `Telescope` cmd 시 로드 |
| nvim-lua/plenary.nvim | telescope 의존성 (lua util) | - | telescope 와 같이 로드 |
| nvim-telescope/telescope-fzf-native.nvim | C 로 컴파일된 fzf 매처 (성능) | Yes | `make` 빌드 필요 |
| nvim-treesitter/nvim-treesitter | AST 기반 문법 하이라이트 + 인덴트 | Yes | `master` 브랜치, `:TSUpdate` 로 parser 빌드 |

> 플러그인 정확한 버전은 `nvim/lazy-lock.json` 에서 관리됩니다.

## tmux 플러그인 (TPM)

| 플러그인 | 역할 | 비고 |
|---|---|---|
| tmux-plugins/tpm | 플러그인 매니저 | |
| tmux-plugins/tmux-sensible | 합리적 기본값 | |
| tmux-plugins/tmux-resurrect | 세션 저장/복원 | prefix + C-s / C-r |
| tmux-plugins/tmux-cpu | CPU/RAM 사용률 (status bar) | `#{cpu_percentage}`, `#{ram_percentage}` |
| tmux-plugins/tmux-battery | 배터리 (status bar) | `#{battery_icon}`, `#{battery_percentage}` |
| tmux-plugins/tmux-prefix-highlight | prefix/copy-mode 시각 표시 | `#{prefix_highlight}` |

## npm 글로벌 패키지

| 패키지 | 역할 |
|---|---|
| @anthropic-ai/claude-code | Claude Code CLI |

## 패키지 추가 절차

1. 이 문서에 패키지 정보 추가
2. 해당 OS 설치 스크립트에 설치 함수 추가
3. CHANGELOG.md 에 기록
4. 테스트: 3개 OS에서 `./install.sh` 실행 확인
