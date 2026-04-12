# Migration Guide

브레이킹 체인지 발생 시 이 문서를 업데이트합니다.

---

## 초기 설정 (2026-04-11)

최초 설치이므로 마이그레이션 없음.

### 기존 Neovim 설정이 있는 경우

```bash
# 기존 설정 백업
mv ~/.config/nvim ~/.config/nvim.bak
mv ~/.local/share/nvim ~/.local/share/nvim.bak
mv ~/.local/state/nvim ~/.local/state/nvim.bak
mv ~/.cache/nvim ~/.cache/nvim.bak

# 새 설정 적용
cd ~/dotfiles
stow nvim
```

### 기존 tmux 설정이 있는 경우

```bash
mv ~/.tmux.conf ~/.tmux.conf.bak
mv ~/.config/tmux ~/.config/tmux.bak

cd ~/dotfiles
stow tmux
```

---

<!-- 새로운 마이그레이션은 위에 추가 -->
