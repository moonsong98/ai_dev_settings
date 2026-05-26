# Migration Guide

Update this document whenever a breaking change is introduced.

---

## Initial setup (2026-04-11)

First-time install — no migration needed.

### If you already have a Neovim config

```bash
# Back up the existing config
mv ~/.config/nvim ~/.config/nvim.bak
mv ~/.local/share/nvim ~/.local/share/nvim.bak
mv ~/.local/state/nvim ~/.local/state/nvim.bak
mv ~/.cache/nvim ~/.cache/nvim.bak

# Apply the new config
cd ~/dotfiles
stow nvim
```

### If you already have a tmux config

```bash
mv ~/.tmux.conf ~/.tmux.conf.bak
mv ~/.config/tmux ~/.config/tmux.bak

cd ~/dotfiles
stow tmux
```

---

<!-- Add new migrations above this line -->
