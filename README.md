# ai_dev_settings

A cross-platform dotfiles repo for a comfortable **Neovim + tmux + Claude Code** workflow.

Designed for daily use across macOS (local laptop) and Linux servers (over SSH), with safe defaults that won't trample your existing `~/.zshrc`.

## Supported OS

| OS | Package manager | Status |
|---|---|---|
| macOS (12+)      | Homebrew | ✅ |
| Ubuntu (20.04+)  | apt      | ✅ |
| CentOS 8 / Stream / Rocky / Alma | dnf | ✅ |

## Requirements

- Git 2.x+
- Neovim **≥ 0.10** (auto-installed by `install.sh`)
- tmux **≥ 3.2**
- Node.js **≥ 18** (for Claude Code CLI)
- GNU Stow

## Quick start

```bash
git clone https://github.com/<your-username>/ai_dev_settings.git ~/ai_dev_settings
cd ~/ai_dev_settings
./install.sh
```

`install.sh` auto-detects the OS, skips packages already present, and is idempotent — safe to re-run after pulling updates.

### What `install.sh` does to your files

| Tool | What happens | Reversible? |
|---|---|---|
| nvim, tmux, starship, claude | Symlinked via Stow → `~/.config/<tool>` | Yes (`stow -D`) |
| zsh (`.zshrc`, `.zprofile`, `.profile`) | **Append only** — a managed block is added at the end; your existing content is untouched | Yes (delete the `# >>> ai_dev_settings >>>` … `# <<< ai_dev_settings <<<` block) |
| oh-my-zsh + community plugins | Installed under `~/.oh-my-zsh/` | Standard oh-my-zsh uninstall |
| TPM + tmux plugins | Installed under `~/.config/tmux/plugins/` | `rm -rf` that dir |

Re-running `install.sh` updates the managed zsh block in place (idempotent).

## Layout

```
ai_dev_settings/
├── install.sh                  # Entry point (OS auto-detect)
├── scripts/                    # Per-OS installers + shared helpers
│   ├── common.sh               # Logging, stow helpers, append-managed-block
│   ├── macos.sh                # Homebrew
│   ├── ubuntu.sh               # apt
│   └── centos.sh               # dnf
├── nvim/                       # → ~/.config/nvim   (Stow)
├── tmux/                       # → ~/.config/tmux   (Stow)
├── starship/                   # → ~/.config/starship.toml (Stow)
├── claude/                     # → ~/.claude       (Stow)
├── zsh/                        # Sourced from your existing rc files (NOT stowed)
│   ├── profile-addon.sh        # POSIX env (PATH, EDITOR, brew, pyenv)
│   ├── zprofile-addon.sh       # zsh login (sources .profile)
│   └── zshrc-addon.zsh         # zsh interactive (omz plugins, starship, pyenv init)
└── docs/                       # Documentation
    ├── KEYMAPS.md
    ├── PACKAGES.md
    ├── TROUBLESHOOTING.md
    └── decisions/              # Architecture decision records (ADRs)
```

## Features at a glance

- **Neovim**: lazy.nvim, tokyonight (transparent), oil.nvim file explorer with git status, gitsigns, telescope (fzf-native), treesitter (`main` branch), lualine, render-markdown, Comment.nvim, nvim-surround. See `docs/KEYMAPS.md`.
- **tmux**: `C-a` prefix, 3-pane Claude layout (`prefix + C-c`), claude HUD indicator on status bar, status-bar **SSH / local indicator with `user@host`** so you always know where you are, CPU/RAM/battery widgets.
- **Starship prompt**: 2-line powerline-flat layout; over SSH, the prompt highlights `user@host` in red so you don't confuse it with a local shell.
- **Claude Code**: pre-wired settings, custom 3-line HUD status line, `claude-usage` CLI shortcut for cumulative cost tracking, project `CLAUDE.md` template.

## Customize

The repo aims to be a drop-in baseline that you then bend to your taste:

- **Per-machine overrides** (not committed): `~/.zshrc.local`, `nvim/lua/config/local.lua`, `tmux/tmux.local.conf`.
- **Neovim plugins**: each plugin lives in its own file under `nvim/.config/nvim/lua/plugins/`. Add a file → restart nvim → lazy.nvim picks it up.
- **OS install steps**: add the install function in `scripts/<os>.sh`, wire it into `install_packages()`, document the package in `docs/PACKAGES.md`.

## Working with Claude Code on this repo

This repo is structured to be friendly to Claude Code itself:

- Conventional Commit messages (`feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `chore:`).
- Small, focused commits — easy to review and revert.
- Architectural decisions go in `docs/decisions/` as ADRs.
- Breaking changes go in `MIGRATION.md`; every notable change goes in `CHANGELOG.md`.

When iterating with Claude:
1. Use `prefix + C-c` to spin up a 3-pane layout (claude / nvim / shell).
2. From visual mode in nvim, `<leader>yr` copies the selected lines with a path header — paste that straight into Claude.
3. The `~/.claude/CLAUDE.md` template (mirrored at `claude/.claude/CLAUDE.md`) is what Claude reads as project instructions. Edit it to set conventions for your project.

## Contributing / sharing

1. Edit the relevant config.
2. Record the change in `CHANGELOG.md`.
3. For breaking changes, also update `MIGRATION.md`.
4. When changing Neovim plugins, commit `lazy-lock.json` along with the change.
5. Test `./install.sh` on a fresh OS (or a clean container) before pushing.

See `docs/PACKAGES.md` for the full package list and `docs/TROUBLESHOOTING.md` for known issues.
