#!/usr/bin/env bash

# Refuse to run if sourced — install.sh uses set -e and bash-only constructs.
# Sourcing from zsh/bash would kill the parent shell on any error (closing
# remote SSH sessions, etc.) and trigger spurious failures like
# "BASH_SOURCE: parameter not set" or zsh treating `path` as the tied PATH array.
if [ "${BASH_SOURCE[0]:-$0}" != "$0" ] || [ -n "${ZSH_VERSION:-}" ]; then
    echo "install.sh must be executed, not sourced:" >&2
    echo "    ./install.sh [--packages-only|--user-only]" >&2
    return 1 2>/dev/null || exit 1
fi

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "${DOTFILES_DIR}/scripts/common.sh"

# ─────────────────────────────────────────────
# CLI flags
# ─────────────────────────────────────────────
DO_PACKAGES=true   # system packages: needs sudo on Linux
DO_USER=true       # dotfiles, oh-my-zsh, TPM, claude-code: all in $HOME

usage() {
    cat <<EOF
Usage: ./install.sh [FLAG]

Without flags, runs the full install: system packages + user-level setup.

Flags:
  --packages-only   Install system packages only (needs sudo on Linux).
                    Use this from a privileged account (e.g. irteamsu).
  --user-only       Install user-level setup only (dotfiles + ~/.npm-global
                    + oh-my-zsh + TPM + claude-code). No sudo required.
                    Use this from your regular account (e.g. irteam) after
                    a sibling account has already run --packages-only.
  --help, -h        Show this help and exit.

Naver-style dual-account workflow (irteam + irteamsu):
  # 1. As irteamsu (has sudo) — install system packages.
  sudo -i -u irteamsu
  cd <repo>; ./install.sh --packages-only
  exit

  # 2. As irteam (your normal user) — install dotfiles into your \$HOME.
  cd <repo>; ./install.sh --user-only
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --packages-only) DO_USER=false; shift ;;
        --user-only)     DO_PACKAGES=false; shift ;;
        -h|--help)       usage; exit 0 ;;
        *)               error "Unknown flag: $1"; usage; exit 1 ;;
    esac
done

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
                    ubuntu|debian)
                        os="ubuntu" ;;
                    centos|rhel|rocky|alma|fedora|amzn|ol|navix)
                        os="centos" ;;
                    *)
                        # Fall back to ID_LIKE so derivatives ("ID_LIKE=rhel
                        # centos fedora") still pick the right installer.
                        case "${ID_LIKE:-}" in
                            *debian*|*ubuntu*)
                                warn "Unknown distribution $ID — using the ubuntu script (matched ID_LIKE=$ID_LIKE)."
                                os="ubuntu"
                                ;;
                            *rhel*|*centos*|*fedora*)
                                warn "Unknown distribution $ID — using the centos script (matched ID_LIKE=$ID_LIKE)."
                                os="centos"
                                ;;
                            *)
                                warn "Unknown Linux distribution: $ID — defaulting to the ubuntu script."
                                os="ubuntu"
                                ;;
                        esac
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
    # NOTE: don't name the loop var "path" — that's a special tied array in zsh
    # (= $PATH) and would error with "inconsistent type for assignment" if this
    # script is accidentally sourced from a zsh shell.
    for f in .zshrc .zprofile .profile; do
        local rc_path="${HOME}/${f}"
        if [ -L "$rc_path" ]; then
            local target
            target=$(readlink "$rc_path")
            # Only unlink symlinks that point into this repo.
            case "$target" in
                "${DOTFILES_DIR}"/*|*/ai_dev_settings/*)
                    info "Unlinking legacy stow symlink: ${rc_path} → ${target}"
                    rm "$rc_path"
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
# Claude Code CLI (npm global)
# ─────────────────────────────────────────────
# When node is installed via the system package manager, the npm global
# prefix (`/usr/local`) is root-owned and `npm i -g` fails with EACCES for
# regular users. Detect that and fall back to a user-local prefix at
# ~/.npm-global, which profile-addon.sh adds to PATH.
install_claude_code() {
    if has_cmd claude; then
        skip "Claude Code CLI already installed"
        return
    fi

    if ! has_cmd npm; then
        warn "npm not found — install Claude Code manually"
        return
    fi

    local npm_prefix
    npm_prefix=$(npm config get prefix 2>/dev/null || echo "")

    if [ -n "$npm_prefix" ] && [ ! -w "$npm_prefix/lib/node_modules" ] && [ ! -w "$npm_prefix/lib" ]; then
        warn "npm global prefix ${npm_prefix} is not user-writable."
        info "Switching npm prefix to ~/.npm-global (no sudo required)."
        mkdir -p "${HOME}/.npm-global"
        npm config set prefix "${HOME}/.npm-global"
        # Make this PATH change effective for the rest of this script run too.
        export PATH="${HOME}/.npm-global/bin:${PATH}"
    fi

    info "Installing Claude Code CLI..."
    if npm install -g @anthropic-ai/claude-code; then
        ok "Claude Code installed — run 'claude' to authenticate"
    else
        error "Claude Code install failed — see npm error above."
        warn "If this is a permissions error, try one of:"
        warn "  sudo npm install -g @anthropic-ai/claude-code"
        warn "  or install node via nvm/volta so npm runs unprivileged"
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
    info "Running as: $(whoami)  HOME=${HOME}"

    if $DO_PACKAGES; then
        info "── Phase 1/2: system packages ──"
        case "$os" in
            macos)  source "${DOTFILES_DIR}/scripts/macos.sh"  ;;
            ubuntu) source "${DOTFILES_DIR}/scripts/ubuntu.sh" ;;
            centos) source "${DOTFILES_DIR}/scripts/centos.sh" ;;
        esac
        install_packages
    else
        skip "── Phase 1/2: system packages — skipped (--user-only) ──"
    fi

    if $DO_USER; then
        info "── Phase 2/2: user-level setup (writes under \$HOME) ──"
        link_configs
        install_zsh_addons
        install_oh_my_zsh
        install_tpm
        install_claude_code
    else
        skip "── Phase 2/2: user-level setup — skipped (--packages-only) ──"
    fi

    echo ""
    ok "Install complete!"
    echo ""
    if $DO_USER; then
        info "Next steps:"
        echo "  0. Make zsh your default shell: chsh -s \"\$(command -v zsh)\"  (needs root/sudo)"
        echo "  1. Restart your terminal, or: source ~/.zshrc"
        echo "  2. Launch nvim → lazy.nvim will auto-install plugins"
        echo "  3. Launch tmux → TPM plugins are already installed (prefix + I only re-installs)"
        echo "  4. Run 'claude' → OAuth authentication"
        echo ""
    else
        info "System packages are in place."
        info "Now switch to your regular user and run:  ./install.sh --user-only"
        echo ""
    fi
}

main "$@"
