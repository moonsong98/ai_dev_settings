# ~/.profile addon — POSIX-compatible login env.
# Sourced from your real ~/.profile via a managed block written by install.sh.
# Both bash login (via ~/.bash_profile fallback) and zsh login (.zprofile sources .profile) read this.
# Do NOT put interactive-only settings (prompt, aliases) here — those go in .zshrc / .bashrc.

# ─── Homebrew (macOS Apple Silicon → Intel) ───
if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi

# ─── pyenv PATH (interactive `pyenv init` lives in zshrc-addon) ───
if [ -d "$HOME/.pyenv" ]; then
    export PYENV_ROOT="$HOME/.pyenv"
    case ":$PATH:" in
        *":$PYENV_ROOT/bin:"*) ;;
        *) PATH="$PYENV_ROOT/bin:$PATH" ;;
    esac
fi

# ─── uv / other user-local binaries ───
if [ -d "$HOME/.local/bin" ]; then
    case ":$PATH:" in
        *":$HOME/.local/bin:"*) ;;
        *) PATH="$HOME/.local/bin:$PATH" ;;
    esac
fi

# ─── npm user-global prefix (used when /usr/local isn't writable) ───
# install.sh sets `npm config set prefix ~/.npm-global` on systems where
# the system npm prefix is root-owned, so user-installed CLIs (e.g.
# @anthropic-ai/claude-code) land here.
if [ -d "$HOME/.npm-global/bin" ]; then
    case ":$PATH:" in
        *":$HOME/.npm-global/bin:"*) ;;
        *) PATH="$HOME/.npm-global/bin:$PATH" ;;
    esac
fi

export PATH

# ─── Default editor (used by git, crontab, fc, ssh, …) ───
# Prefer nvim, then vim, then vi.
if command -v nvim >/dev/null 2>&1; then
    export EDITOR=nvim
elif command -v vim >/dev/null 2>&1; then
    export EDITOR=vim
else
    export EDITOR=vi
fi
export VISUAL="$EDITOR"
