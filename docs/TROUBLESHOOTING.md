# Troubleshooting

OS별 자주 발생하는 문제와 해결법.

---

## 공통

### Neovim: 외부 파일 변경이 반영되지 않음

Claude Code가 파일을 수정했는데 Neovim에 반영 안 될 때:

```
원인: autoread가 특정 이벤트에서만 트리거됨
해결: 이 dotfiles의 autocmds.lua에 FocusGained/CursorHold 이벤트가 설정되어 있음
확인: tmux.conf에 `set -g focus-events on` 이 있는지 확인
```

### lazy.nvim: 플러그인 설치 실패

```bash
# 캐시 초기화
rm -rf ~/.local/share/nvim/lazy
rm -rf ~/.cache/nvim

# nvim 재실행 → lazy.nvim이 자동 재설치
nvim
```

### tmux: 플러그인이 설치 안 됨

```bash
# TPM이 설치되어 있는지 확인
ls ~/.tmux/plugins/tpm

# 없으면 수동 설치
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# tmux 실행 후
# prefix + I (대문자 I) 로 플러그인 설치
```

### Claude Code: 인증 오류

```bash
# 재인증
claude auth

# 환경변수 확인
echo $ANTHROPIC_API_KEY

# .bashrc 또는 .zshrc에 있는지 확인
grep ANTHROPIC ~/.bashrc ~/.zshrc 2>/dev/null
```

---

## macOS

### Neovim: clipboard 동작 안 함

```
원인: pbcopy/pbpaste가 tmux 안에서 동작하지 않을 때
해결: brew install reattach-to-user-namespace (최신 tmux에서는 불필요)
확인: tmux.conf에 set -g set-clipboard on 있는지 확인
```

### brew: permission denied

```bash
sudo chown -R $(whoami) /usr/local/share/zsh /usr/local/share/zsh/site-functions
```

---

## Ubuntu

### Neovim: PPA 버전이 낮음

```bash
# 수동으로 최신 appimage 설치
curl -fLo /tmp/nvim.appimage \
    https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage
chmod u+x /tmp/nvim.appimage
sudo mv /tmp/nvim.appimage /usr/local/bin/nvim
```

### fd: command not found

Ubuntu에서는 `fd-find` 패키지가 `fdfind`로 설치됨:

```bash
# 심링크 생성
sudo ln -sf $(which fdfind) /usr/local/bin/fd
```

### clipboard: xclip vs xsel

```bash
# 둘 중 하나 설치
sudo apt install xclip
# 또는
sudo apt install xsel

# SSH 환경에서는 OSC 52 사용 (tmux가 지원)
```

---

## CentOS 8

### Neovim: EPEL 버전이 너무 낮음

CentOS 8 EPEL의 neovim은 0.4.x일 수 있음:

```bash
# appimage 사용 (install.sh가 자동 처리)
curl -fLo /tmp/nvim.appimage \
    https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage
chmod u+x /tmp/nvim.appimage
sudo mv /tmp/nvim.appimage /usr/local/bin/nvim

# FUSE 없이 실행해야 할 경우
# ./nvim.appimage --appimage-extract
# sudo mv squashfs-root /opt/nvim
# sudo ln -sf /opt/nvim/AppRun /usr/local/bin/nvim
```

### CentOS 8 EOL 관련

CentOS 8은 2021년에 EOL. CentOS Stream 8 또는 Rocky/Alma로 전환 권장.
repo가 동작하지 않으면:

```bash
# vault로 repo 변경
sudo sed -i 's|mirrorlist=|#mirrorlist=|g' /etc/yum.repos.d/CentOS-*.repo
sudo sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*.repo
```

### tmux: 버전이 낮음 (2.x)

```bash
# 소스 빌드
sudo dnf install -y libevent-devel ncurses-devel
git clone https://github.com/tmux/tmux.git /tmp/tmux-build
cd /tmp/tmux-build
git checkout 3.5a
sh autogen.sh
./configure && make
sudo make install
```

### Node.js: dnf module 충돌

```bash
# 기존 nodejs module 리셋
sudo dnf module reset nodejs
sudo dnf module enable nodejs:18
sudo dnf install -y nodejs
```
