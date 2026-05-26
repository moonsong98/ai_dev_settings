# Troubleshooting

Common problems and fixes, grouped by OS.

---

## Common

### Neovim: external file changes don't show up

When Claude Code edits a file but the change isn't reflected in Neovim:

```
Cause: autoread only fires on specific events.
Fix:   autocmds.lua in this dotfiles wires up FocusGained/CursorHold.
Check: confirm `set -g focus-events on` is set in tmux.conf.
```

### lazy.nvim: plugin install fails

```bash
# Clear the cache
rm -rf ~/.local/share/nvim/lazy
rm -rf ~/.cache/nvim

# Relaunch nvim → lazy.nvim re-installs automatically
nvim
```

### tmux: plugins not installed

```bash
# Confirm TPM is in place
ls ~/.tmux/plugins/tpm

# Install manually if missing
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Launch tmux, then:
# prefix + I  (capital I) to install plugins
```

### Claude Code: authentication error

```bash
# Re-authenticate
claude auth

# Check env vars
echo $ANTHROPIC_API_KEY

# Confirm the var is set in .bashrc or .zshrc
grep ANTHROPIC ~/.bashrc ~/.zshrc 2>/dev/null
```

---

## macOS

### Neovim: clipboard doesn't work

```
Cause: pbcopy/pbpaste sometimes don't work inside tmux.
Fix:   brew install reattach-to-user-namespace (not needed on recent tmux).
Check: confirm `set -g set-clipboard on` is in tmux.conf.
```

### brew: permission denied

```bash
sudo chown -R $(whoami) /usr/local/share/zsh /usr/local/share/zsh/site-functions
```

---

## Ubuntu

### Neovim: PPA version is too old

```bash
# Install the latest appimage manually
curl -fLo /tmp/nvim.appimage \
    https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage
chmod u+x /tmp/nvim.appimage
sudo mv /tmp/nvim.appimage /usr/local/bin/nvim
```

### fd: command not found

On Ubuntu the `fd-find` package installs the binary as `fdfind`:

```bash
# Create a symlink
sudo ln -sf $(which fdfind) /usr/local/bin/fd
```

### clipboard: xclip vs xsel

```bash
# Install either one
sudo apt install xclip
# or
sudo apt install xsel

# Over SSH, use OSC 52 (tmux supports this)
```

---

## CentOS 8

### Neovim: EPEL version is far too old

CentOS 8 EPEL may ship neovim 0.4.x:

```bash
# Use the upstream appimage (install.sh handles this automatically)
curl -fLo /tmp/nvim.appimage \
    https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage
chmod u+x /tmp/nvim.appimage
sudo mv /tmp/nvim.appimage /usr/local/bin/nvim

# If FUSE isn't available, extract and run unpacked
# ./nvim.appimage --appimage-extract
# sudo mv squashfs-root /opt/nvim
# sudo ln -sf /opt/nvim/AppRun /usr/local/bin/nvim
```

### CentOS 8 EOL notes

CentOS 8 reached EOL in 2021. Switch to CentOS Stream 8 or Rocky/Alma.
If the upstream repos don't resolve any more:

```bash
# Point the repos at the vault
sudo sed -i 's|mirrorlist=|#mirrorlist=|g' /etc/yum.repos.d/CentOS-*.repo
sudo sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*.repo
```

### tmux: version too low (2.x)

```bash
# Build from source
sudo dnf install -y libevent-devel ncurses-devel
git clone https://github.com/tmux/tmux.git /tmp/tmux-build
cd /tmp/tmux-build
git checkout 3.5a
sh autogen.sh
./configure && make
sudo make install
```

### Node.js: dnf module conflict

```bash
# Reset the existing nodejs module
sudo dnf module reset nodejs
sudo dnf module enable nodejs:18
sudo dnf install -y nodejs
```
