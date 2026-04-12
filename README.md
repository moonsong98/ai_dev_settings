# dotfiles

Neovim + tmux + Claude Code 크로스 플랫폼 개발 환경.

## 지원 OS

| OS | 패키지 매니저 | 상태 |
|---|---|---|
| macOS (12+) | Homebrew | ✅ |
| Ubuntu (20.04+) | apt | ✅ |
| CentOS 8 / Stream | dnf | ✅ |

## 요구사항

- Git 2.x+
- Neovim **≥ 0.10** (install 스크립트가 자동 설치)
- tmux **≥ 3.2**
- Node.js **≥ 18** (Claude Code 용)
- GNU Stow

## 퀵스타트

```bash
git clone https://github.com/<your-username>/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

install.sh 는 OS를 자동 감지하고, 이미 설치된 패키지는 건너뜁니다.

## 구조

```
dotfiles/
├── install.sh              # 엔트리포인트 (OS 자동 감지)
├── scripts/                # OS별 설치 스크립트
├── nvim/                   # → ~/.config/nvim
├── tmux/                   # → ~/.config/tmux
├── claude/                 # → ~/.claude
└── docs/                   # 문서
```

## 패키지 추가/변경 시

1. 설정 파일 수정
2. `CHANGELOG.md` 에 변경 내역 기록
3. 브레이킹 체인지라면 `MIGRATION.md` 도 업데이트
4. Neovim 플러그인 변경 시 `lazy-lock.json` 커밋 포함

자세한 패키지 목록은 [docs/PACKAGES.md](docs/PACKAGES.md) 참고.
