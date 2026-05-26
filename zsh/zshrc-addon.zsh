# ~/.zshrc addon — interactive zsh setup added on TOP of your existing ~/.zshrc.
# Sourced from your real ~/.zshrc via a managed block written by install.sh.
# Keep this safe to source AFTER oh-my-zsh has already loaded.

# ─── oh-my-zsh community plugins (manual-source variant) ───
# We source these directly instead of touching your `plugins=(…)` line so we
# don't fight your existing oh-my-zsh setup. install.sh git-clones them into
# $ZSH_CUSTOM/plugins/ for you.
if [ -n "$ZSH" ] && [ -d "$ZSH/custom/plugins" ]; then
    local _omz_custom="${ZSH_CUSTOM:-$ZSH/custom}/plugins"
    [ -f "$_omz_custom/zsh-autosuggestions/zsh-autosuggestions.zsh" ] && \
        source "$_omz_custom/zsh-autosuggestions/zsh-autosuggestions.zsh"
    # syntax-highlighting MUST be the last sourced plugin per its README.
    [ -f "$_omz_custom/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ] && \
        source "$_omz_custom/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
    unset _omz_custom
fi

# ─── pyenv interactive init (PATH lives in ~/.profile) ───
command -v pyenv >/dev/null 2>&1 && eval "$(pyenv init -)"

# ─── iTerm shell integration (macOS only, file-present guard) ───
[ -f "${HOME}/.iterm2_shell_integration.zsh" ] && source "${HOME}/.iterm2_shell_integration.zsh"

# ─── Starship prompt (when installed) ───
command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"

# ─── Local per-machine override (not committed to git) ───
[ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"
