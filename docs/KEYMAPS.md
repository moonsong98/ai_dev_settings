# Keymap cheatsheet

## Neovim

Leader: `Space`

### Basic

| Key | Mode | Action |
|---|---|---|
| `jk` | Insert | Esc |
| `<leader>w` | Normal | Save |
| `<leader>q` | Normal | Quit |
| `<Esc>` | Normal | Clear search highlight |

### Window navigation

| Key | Action |
|---|---|
| `C-h/j/k/l` | Move window (left/down/up/right) |
| `C-Up/Down/Left/Right` | Resize window |

### Buffers

| Key | Action |
|---|---|
| `S-h` | Previous buffer |
| `S-l` | Next buffer |

### File explorer (oil.nvim)

| Key | Mode | Action |
|---|---|---|
| `-` | Normal | Open the current buffer's directory in oil (inside oil = parent dir) |
| `<leader>e` | Normal | Same (e = explorer) |

Inside an oil buffer:
- `<CR>` open file / descend into directory
- Add a line to create a new file/directory, `dd` to delete, `cw` to rename
- `:w` write changes to disk
- `q` close

### Git (gitsigns.nvim)

| Key | Mode | Action |
|---|---|---|
| `]h` / `[h` | Normal | Next / previous hunk |
| `<leader>hp` | Normal | Preview hunk (floating) |
| `<leader>hd` | Normal | Diff current buffer vs HEAD |
| `<leader>hb` | Normal | Blame the line (full info, floating) |
| `<leader>tb` | Normal | Toggle inline blame |
| `<leader>hs` | Normal | Stage hunk (= git add) |
| `<leader>hr` | Normal | Reset hunk (revert change) |
| `<leader>hS` / `<leader>hR` | Normal | Stage / reset entire buffer |
| `<leader>td` | Normal | Toggle inline deleted-line view |
| `ih` | Operator/Visual | Hunk text object (`vih`, `dih`, `yih`, …) |

### Telescope (fuzzy finder)

| Key | Action |
|---|---|
| `<leader>ff` | Find file (fd) |
| `<leader>fg` | Live grep (rg) |
| `<leader>fs` | Grep word under cursor |
| `<leader>fr` | Recently opened files (oldfiles) |
| `<leader>fb` | Switch buffer |
| `<leader>fh` | Search vim help |
| `<leader>fk` | Search keymaps |
| `<leader>fc` | Search commands |
| `<leader>gb` | git branches |
| `<leader>gs` | git modified files |
| `<leader>gc` | git commit log |
| `<leader>f.` | Resume last picker |

Inside a telescope picker:
- `<C-n>` / `<C-p>` or `<C-j>` / `<C-k>` — move selection
- `<CR>` — accept
- `<C-x>` open in horizontal split, `<C-v>` vertical split, `<C-t>` new tab
- `<C-/>` help in insert mode, `?` in normal mode

### Comments (Comment.nvim)

| Key | Mode | Action |
|---|---|---|
| `Ctrl+/` | Normal | Toggle current line comment (VSCode-style) |
| `Ctrl+/` | Visual | Toggle comment on selection |
| `gcc` | Normal | Toggle current line comment (vim standard) |
| `gbc` | Normal | Toggle block comment |
| `gc{motion}` | Normal | Comment over motion (`gcap` paragraph, `gc5j` next 5 lines, `gcG` to EOF) |
| `gc` | Visual | Comment selection |
| `gco` / `gcO` | Normal | Add comment line below / above and enter insert |
| `gcA` | Normal | Add comment at end of line and enter insert |

### Surround (nvim-surround)

| Key | Mode | Action |
|---|---|---|
| `cs"'` | Normal | `"x"` → `'x'` (change surround) |
| `cs)]` | Normal | `(x)` → `[x]` |
| `ds"` | Normal | `"x"` → `x` (delete surround) |
| `ysiw"` | Normal | `word` → `"word"` (yank-surround inner word) |
| `yss)` | Normal | Wrap the entire line in `(...)` |
| `S"` | Visual | Wrap the selection in `"..."` |

Prefix summary: `cs` change · `ds` delete · `ys` add (yank) · `S` (visual) add

### Claude Code integration

| Key | Mode | Action |
|---|---|---|
| `<leader>yr` | Visual | Copy selection + relative path (paste into Claude) |

### Visual mode

| Key | Action |
|---|---|
| `J` / `K` | Move lines down / up |
| `<` / `>` | Indent (preserves selection) |
| `<leader>p` | Paste without overwriting the unnamed register |

---

## tmux

Prefix: `C-a`

### Basic

| Key | Action |
|---|---|
| `prefix + \|` | Split vertically |
| `prefix + -` | Split horizontally |
| `prefix + c` | New window |
| `prefix + r` | Reload config |

### Pane navigation / resize

| Key | Action |
|---|---|
| `prefix + h/j/k/l` | Move between panes |
| `prefix + H/J/K/L` | Resize panes |

### Claude Code

| Key | Action |
|---|---|
| `prefix + C` | Open a Claude Code pane (right 40%) |
| `prefix + C-c` | Rebuild window: 3-pane layout (claude / nvim / shell) |

### Sessions

| Key | Action |
|---|---|
| `prefix + C-s` | Save session (resurrect) |
| `prefix + C-r` | Restore session (resurrect) |
| `prefix + d` | Detach |
| `prefix + [` | Copy mode (vi keybindings) |
