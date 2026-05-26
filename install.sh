#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "${DOTFILES_DIR}/scripts/common.sh"

# ─────────────────────────────────────────────
# OS detection
# ─────────────────────────────────────────────
detect_os() {
    local os=""
    case "$(uname -s)" in
        Darwin)
            os="macos"
            ;;
        Linux)
            if [ -f /etc/os-release ]; then
                . /etc/os-release
                case "$ID" in
                    ubuntu|debian)  os="ubuntu" ;;
                    centos|rhel|rocky|alma)  os="centos" ;;
                    *)
                        warn "Unknown Linux distribution: $ID — trying the ubuntu script."
                        os="ubuntu"
                        ;;
                esac
            fi
            ;;
        *)
            error "Unsupported OS: $(uname -s)"
            exit 1
            ;;
    esac
    echo "$os"
}

# ─────────────────────────────────────────────
# Remove any previous zsh stow symlinks the old installer may have created.
# We now manage zsh via appended managed blocks instead.
# ─────────────────────────────────────────────
unlink_legacy_zsh_stow() {
    for f in .zshrc .zprofile .profile; do
        local path="${HOME}/${f}"
        if [ -L "$path" ]; then
            local target
            target=$(readlink "$path")
            # Only unlink symlinks that point into this repo.
            case "$target" in
                "${DOTFILES_DIR}"/*|*/ai_dev_settings/*)
                    info "Unlinking legacy stow symlink: ${path} → ${target}"
                    rm "$path"
                    ;;
            esac
        fi
    done
}

# ─────────────────────────────────────────────
# Symlink configs via Stow (nvim, tmux, starship, claude)
# ─────────────────────────────────────────────
link_configs() {
    info "Creating symlinks..."

    mkdir -p "${HOME}/.config"

    # nvim → ~/.config/nvim
    stow -d "${DOTFILES_DIR}" -t "${HOME}" --ignore='\.DS_Store' nvim 2>/dev/null || {
        warn "nvim stow conflict — backing up existing config."
        backup_and_stow "nvim" "${HOME}/.config/nvim"
    }

    # tmux → ~/.config/tmux
    # plugins/ is populated by TPM at runtime, so it must be excluded from stow.
    stow -d "${DOTFILES_DIR}" -t "${HOME}" --ignore='\.DS_Store' --ignore='plugins' tmux 2>/dev/null || {
        warn "tmux stow conflict — backing up existing config."
        backup_and_stow "tmux" "${HOME}/.config/tmux"
    }

    # starship → ~/.config/starship.toml
    stow -d "${DOTFILES_DIR}" -t "${HOME}" --ignore='\.DS_Store' starship 2>/dev/null || {
        warn "starship stow conflict — backing up existing config."
        if [ -e "${HOME}/.config/starship.toml" ] && [ ! -L "${HOME}/.config/starship.toml" ]; then
            local backup="${HOME}/.config/starship.toml.bak.$(date +%Y%m%d%H%M%S)"
            mv "${HOME}/.config/starship.toml" "${backup}"
            info "Backup: starship.toml → ${backup}"
        fi
        stow -d "${DOTFILES_DIR}" -t "${HOME}" --ignore='\.DS_Store' starship
        ok "starship stow done"
    }

    # claude → ~/.claude
    # plugins/marketplaces/gp-settings/ is where statusline.mjs caches files; it
    # must remain a real directory rather than a folded symlink (otherwise the
    # cache writes leak into the repo). Pre-create it.
    mkdir -p "${HOME}/.claude/plugins/marketplaces/gp-settings"
    stow -d "${DOTFILES_DIR}" -t "${HOME}" --ignore='\.DS_Store' claude 2>/dev/null || {
        warn "claude stow conflict — backing up existing dotfiles."
        for f in settings.json CLAUDE.md usage-report.py plugins/marketplaces/gp-settings/statusline.mjs; do
            if [ -e "${HOME}/.claude/${f}" ] && [ ! -L "${HOME}/.claude/${f}" ]; then
                local backup="${HOME}/.claude/${f}.bak.$(date +%Y%m%d%H%M%S)"
                mv "${HOME}/.claude/${f}" "${backup}"
                info "Backup: ${HOME}/.claude/${f} → ${backup}"
            fi
        done
        stow -d "${DOTFILES_DIR}" -t "${HOME}" --ignore='\.DS_Store' claude
    }

    # claude-usage CLI shortcut (~/.local/bin is added to PATH by ~/.profile).
    if [ -e "${HOME}/.claude/usage-report.py" ]; then
        mkdir -p "${HOME}/.local/bin"
        ln -sf "${HOME}/.claude/usage-report.py" "${HOME}/.local/bin/claude-usage"
        ok "claude-usage → ~/.local/bin/"
    fi

    ok "Symlinks done"
}

# ─────────────────────────────────────────────
# Append (not replace) zsh dotfiles.
# A managed block is added at the end of each rc file; existing user content
# is preserved untouched.
# ─────────────────────────────────────────────
install_zsh_addons() {
    info "Installing zsh addons (append mode — your existing rc files are kept)..."
    unlink_legacy_zsh_stow

    append_managed_block "${HOME}/.profile"  "${DOTFILES_DIR}/zsh/profile-addon.sh"   "posix"
    append_managed_block "${HOME}/.zprofile" "${DOTFILES_DIR}/zsh/zprofile-addon.sh"  "posix"
    append_managed_block "${HOME}/.zshrc"    "${DOTFILES_DIR}/zsh/zshrc-addon.zsh"    "zsh"
}

# ─────────────────────────────────────────────
# oh-my-zsh framework + community plugins
# ─────────────────────────────────────────────
install_oh_my_zsh() {
    # Framework itself.
    if [ -d "${HOME}/.oh-my-zsh" ]; then
        skip "oh-my-zsh already installed"
    else
        info "Installing oh-my-zsh..."
        # --unattended: skip prompt / chsh / spawning a zsh shell.
        # --keep-zshrc: keep the user's existing ~/.zshrc.
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc >/dev/null
        ok "oh-my-zsh installed"
    fi

    # Community plugins (sourced by the managed block in zshrc-addon.zsh).
    local custom_dir="${HOME}/.oh-my-zsh/custom/plugins"
    mkdir -p "$custom_dir"

    if [ -d "${custom_dir}/zsh-autosuggestions" ]; then
        skip "zsh-autosuggestions already installed"
    else
        info "Installing zsh-autosuggestions..."
        git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions "${custom_dir}/zsh-autosuggestions"
        ok "zsh-autosuggestions installed"
    fi

    if [ -d "${custom_dir}/zsh-syntax-highlighting" ]; then
        skip "zsh-syntax-highlighting already installed"
    else
        info "Installing zsh-syntax-highlighting..."
        git clone --depth 1 https://github.com/zsh-users/zsh-syntax-highlighting.git "${custom_dir}/zsh-syntax-highlighting"
        ok "zsh-syntax-highlighting installed"
    fi
}

# ─────────────────────────────────────────────
# TPM (Tmux Plugin Manager) + auto-install declared plugins
# ─────────────────────────────────────────────
install_tpm() {
    local tpm_dir="${HOME}/.config/tmux/plugins/tpm"
    if [ -d "$tpm_dir" ]; then
        skip "TPM already installed"
    else
        info "Installing TPM..."
        mkdir -p "$(dirname "$tpm_dir")"
        git clone https://github.com/tmux-plugins/tpm "$tpm_dir"
        ok "TPM installed"
    fi

    # Idempotently install the plugins declared in tmux.conf.
    if [ -x "${tpm_dir}/scripts/install_plugins.sh" ]; then
        info "Installing tmux plugins..."
        "${tpm_dir}/scripts/install_plugins.sh" >/dev/null 2>&1 || \
            warn "tmux plugin install failed — retry inside tmux with prefix + I"
        ok "tmux plugins installed"
    fi
}

# ─────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────
main() {
    echo ""
    echo "╔══════════════════════════════════════╗"
    echo "║     dotfiles installer               ║"
    echo "║     nvim + tmux + claude code        ║"
    echo "╚══════════════════════════════════════╝"
    echo ""

    local os
    os=$(detect_os)
    info "Detected OS: ${os}"

    # OS-specific package install.
    case "$os" in
        macos)  source "${DOTFILES_DIR}/scripts/macos.sh"  ;;
        ubuntu) source "${DOTFILES_DIR}/scripts/ubuntu.sh" ;;
        centos) source "${DOTFILES_DIR}/scripts/centos.sh" ;;
    esac

    install_packages

    # Shared config.
    link_configs
    install_zsh_addons
    install_oh_my_zsh
    install_tpm

    # Claude Code (npm global).
    if has_cmd claude; then
        skip "Claude Code CLI already installed"
    else
        if has_cmd npm; then
            info "Installing Claude Code CLI..."
            npm install -g @anthropic-ai/claude-code
            ok "Claude Code installed — run 'claude' to authenticate"
        else
            warn "npm not found — install Claude Code manually"
        fi
    fi

    echo ""
    ok "Install complete!"
    echo ""
    info "Next steps:"
    echo "  0. Make zsh your default shell: chsh -s \"\$(command -v zsh)\"  (needs root/sudo)"
    echo "  1. Restart your terminal, or: source ~/.zshrc"
    echo "  2. Launch nvim → lazy.nvim will auto-install plugins"
    echo "  3. Launch tmux → TPM plugins are already installed (prefix + I only re-installs)"
    echo "  4. Run 'claude' → OAuth authentication"
    echo ""
}

main "$@"
