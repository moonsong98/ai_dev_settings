# dotfiles

A cross-platform development environment for Neovim + tmux + Claude Code.

## Supported OS

| OS | Package Manager | Status |
|---|---|---|
| macOS (12+) | Homebrew | ✅ |
| Ubuntu (20.04+) | apt | ✅ |
| CentOS 8 / Stream | dnf | ✅ |

## Requirements

- Git 2.x+
- Neovim **≥ 0.10** (auto-installed by the install script)
- tmux **≥ 3.2**
- Node.js **≥ 18** (for Claude Code)
- GNU Stow

## Quick start

```bash
git clone https://github.com/<your-username>/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

`install.sh` auto-detects the OS and skips packages that are already installed.

## Layout

```
dotfiles/
├── install.sh              # Entry point (OS auto-detect)
├── scripts/                # Per-OS installer scripts
├── nvim/                   # → ~/.config/nvim
├── tmux/                   # → ~/.config/tmux
├── zsh/                    # → ~/.zshrc, ~/.zprofile, ~/.profile
├── starship/               # → ~/.config/starship.toml
├── claude/                 # → ~/.claude
└── docs/                   # Documentation
```

## Adding or changing a package

1. Edit the relevant config.
2. Record the change in `CHANGELOG.md`.
3. For breaking changes, also update `MIGRATION.md`.
4. When updating Neovim plugins, commit `lazy-lock.json` along with the change.

See [docs/PACKAGES.md](docs/PACKAGES.md) for the full package list.
