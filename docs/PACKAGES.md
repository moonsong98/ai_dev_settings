# Packages

Inventory of installed packages and what each one does.
**Always update `CHANGELOG.md` when this file changes.**

## System packages

| Package | Min version | Tested version | Role | Notes |
|---|---|---|---|---|
| neovim | 0.10.0 | 0.11.x | Editor | appimage on CentOS |
| tmux | 3.2 | 3.5a | Terminal multiplexer | |
| node | 18.x | 22.x LTS | Claude Code runtime | |
| git | 2.x | 2.45 | Version control | |
| stow | 2.x | 2.4.0 | Symlink management | |
| ripgrep | 13.x | 14.x | Search (grep replacement) | |
| fd | 8.x | 10.x | File finder (find replacement) | |
| fzf | 0.40+ | 0.57 | Fuzzy finder | |
| starship | 1.x | 1.25 | Cross-shell prompt | Linux uses install.sh (not apt/dnf) |
| tree-sitter (CLI) | 0.20+ | 0.26 | Used by nvim-treesitter `main` branch to build parsers | brew `tree-sitter-cli`, GitHub release on Linux |

## Neovim plugins (lazy.nvim)

| Plugin | Role | lazy? | Notes |
|---|---|---|---|
| folke/lazy.nvim | Plugin manager | - | Bootstrap |
| folke/tokyonight.nvim | Colorscheme | No | priority=1000 |
| folke/which-key.nvim | Keymap helper popup | Yes | VeryLazy |
| stevearc/oil.nvim | File explorer (directory as buffer) | No | `-` / `<leader>e` |
| refractalize/oil-git-status.nvim | git status column inside oil | Yes | User OilEnter |
| lewis6991/gitsigns.nvim | git diff in sign column + hunk actions | Yes | Loads on BufReadPre |
| nvim-telescope/telescope.nvim | Fuzzy finder (files / grep / buffer / git / …) | Yes | Loads on `Telescope` cmd |
| nvim-lua/plenary.nvim | telescope dep (lua util) | - | Loads with telescope |
| nvim-telescope/telescope-fzf-native.nvim | fzf matcher compiled in C (perf) | Yes | Needs `make` build |
| nvim-treesitter/nvim-treesitter | AST-based syntax highlight + indent | Yes | `main` branch, `:TSUpdate` builds parsers |
| numToStr/Comment.nvim | Toggle comments (`gcc`, `gc`, `gbc`, …) | Yes | BufReadPost |
| kylechui/nvim-surround | Edit surroundings (`cs`, `ds`, `ys`) | Yes | BufReadPost |
| nvim-lualine/lualine.nvim | Rich statusline | Yes | VeryLazy |
| nvim-tree/nvim-web-devicons | Filetype icons (Nerd Font) | - | lualine dep |
| MeanderingProgrammer/render-markdown.nvim | In-buffer markdown rendering | Yes | `ft = markdown` |

> Exact plugin versions are pinned in `nvim/.config/nvim/lazy-lock.json`.

## tmux plugins (TPM)

| Plugin | Role | Notes |
|---|---|---|
| tmux-plugins/tpm | Plugin manager | |
| tmux-plugins/tmux-sensible | Sensible defaults | |
| tmux-plugins/tmux-resurrect | Save/restore sessions | prefix + C-s / C-r |
| tmux-plugins/tmux-cpu | CPU/RAM in status bar | `#{cpu_percentage}`, `#{ram_percentage}` |
| tmux-plugins/tmux-battery | Battery in status bar | `#{battery_icon}`, `#{battery_percentage}` |
| tmux-plugins/tmux-prefix-highlight | Visual indicator for prefix/copy mode | `#{prefix_highlight}` |

## npm global packages

| Package | Role |
|---|---|
| @anthropic-ai/claude-code | Claude Code CLI |

## Adding a new package

1. Document the package in this file.
2. Add an install function in the relevant OS script (`scripts/<os>.sh`).
3. Record the change in `CHANGELOG.md`.
4. Test: run `./install.sh` on all three target OSes.
