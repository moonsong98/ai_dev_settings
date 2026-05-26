# Changelog

All notable changes to this project are recorded in this file.
Format: [Keep a Changelog](https://keepachangelog.com/en/1.1.0/)

## [2026-05-25] - Layout · env consistency · install.sh cleanup · starship customization

### Added
- **tmux**: `prefix + C-c` 3-pane layout (left 50% claude · top-right 65% nvim · bottom-right 35% shell)
  - Other panes in the same window are force-killed and rebuilt (idempotent)
- **tmux**: claude HUD indicator on status-left — green `● claude` when a claude pane exists in the session
- **zsh**: added `~/.profile` (POSIX-compatible env) — bash login uses the same PATH/env
  - `.zprofile` sources `.profile`
  - Removed duplicate pyenv/uv PATH exports from `.zshrc`
- **starship**: new stow package `starship/` for `~/.config/starship.toml`
  - 2-line powerline-flat style (┏━ … / ┗━❯)
  - directory · git branch/status · nodejs/python/rust/golang · cmd_duration
- **install.sh**:
  - Added zsh stow + starship stow
  - tmux stow now uses `--ignore='plugins'`
  - Updated TPM path to `~/.config/tmux/plugins/tpm`
  - After installing TPM, automatically runs `install_plugins.sh` (no need for manual `prefix + I`)

### Fixed
- **tmux**: `prefix + C-c` previously split the current pane further; now it cleans up other panes with `kill-pane -a` and rebuilds → pressing it anywhere always yields the same 3-pane shape

### Removed
- **tmux**: cleaned up 3 orphan git submodule refs under `tmux/.config/tmux/plugins/`

## [2026-05-24] - tmux HUD · zsh · starship

### Added
- **tmux**:
  - `set -g mouse on` (mouse scroll / pane selection)
  - iTerm tab title: `set-titles on` + `set-titles-string "#S · #W"`
  - Added HUD plugins: tmux-cpu, tmux-battery, tmux-prefix-highlight
  - Status bar shows git branch (inline), CPU / RAM / battery / time
- **zsh**: new stow package (`zsh/`) — ported existing ~/.zshrc, includes starship init, added cross-platform guards
- **starship**: cross-shell prompt (identical between bash/zsh)
  - Install function added to all macos / ubuntu / centos scripts

### Fixed
- **tmux**: `pane_current_command` was being captured as the Claude version string (e.g. "2.1.150"), making window names look like version numbers → use `automatic-rename-format` regex to substitute "claude"
- **tmux**: unified TPM path (`~/.tmux/plugins` → `~/.config/tmux/plugins`)

## [2026-04-11] - Initial setup

### Added
- **nvim**: lazy.nvim-based base structure (pure config, no plugins yet)
  - Basic options (line numbers, tabs, search, etc.)
  - Basic keymaps
  - lazy.nvim bootstrap
- **tmux**: base config
  - prefix: `C-a`
  - vi-mode keybindings
  - Per-OS clipboard integration
  - TPM (Tmux Plugin Manager) bootstrap
- **claude**: Claude Code base config
  - settings.json template
  - CLAUDE.md project instruction template
- **scripts**: cross-platform install scripts
  - macOS (Homebrew)
  - Ubuntu (apt)
  - CentOS 8 (dnf)
  - Skip-if-already-installed logic
- **docs**: initial documentation
  - PACKAGES.md, KEYMAPS.md, TROUBLESHOOTING.md
