#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "${DOTFILES_DIR}/scripts/common.sh"

# ─────────────────────────────────────────────
# OS 감지
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
                        warn "알 수 없는 Linux 배포판: $ID — ubuntu 스크립트로 시도합니다."
                        os="ubuntu"
                        ;;
                esac
            fi
            ;;
        *)
            error "지원하지 않는 OS: $(uname -s)"
            exit 1
            ;;
    esac
    echo "$os"
}

# ─────────────────────────────────────────────
# Stow로 심링크 생성
# ─────────────────────────────────────────────
link_configs() {
    info "심링크 생성 중..."

    mkdir -p "${HOME}/.config"

    # nvim → ~/.config/nvim
    stow -d "${DOTFILES_DIR}" -t "${HOME}" --ignore='\.DS_Store' nvim 2>/dev/null || {
        warn "nvim stow 충돌 — 기존 설정을 백업합니다."
        backup_and_stow "nvim" "${HOME}/.config/nvim"
    }

    # tmux → ~/.config/tmux
    # plugins/ 는 TPM 이 직접 채우는 디렉토리이므로 stow 대상에서 제외
    stow -d "${DOTFILES_DIR}" -t "${HOME}" --ignore='\.DS_Store' --ignore='plugins' tmux 2>/dev/null || {
        warn "tmux stow 충돌 — 기존 설정을 백업합니다."
        backup_and_stow "tmux" "${HOME}/.config/tmux"
    }

    # zsh → ~/.zshrc, ~/.zprofile, ~/.profile (개별 dotfile 들)
    stow -d "${DOTFILES_DIR}" -t "${HOME}" --ignore='\.DS_Store' zsh 2>/dev/null || {
        warn "zsh stow 충돌 — 기존 dotfile 을 백업합니다."
        for f in .zshrc .zprofile .profile; do
            if [ -e "${HOME}/${f}" ] && [ ! -L "${HOME}/${f}" ]; then
                local backup="${HOME}/${f}.bak.$(date +%Y%m%d%H%M%S)"
                mv "${HOME}/${f}" "${backup}"
                info "백업: ${HOME}/${f} → ${backup}"
            fi
        done
        stow -d "${DOTFILES_DIR}" -t "${HOME}" --ignore='\.DS_Store' zsh
        ok "zsh stow 완료"
    }

    # starship → ~/.config/starship.toml
    stow -d "${DOTFILES_DIR}" -t "${HOME}" --ignore='\.DS_Store' starship 2>/dev/null || {
        warn "starship stow 충돌 — 기존 설정을 백업합니다."
        if [ -e "${HOME}/.config/starship.toml" ] && [ ! -L "${HOME}/.config/starship.toml" ]; then
            local backup="${HOME}/.config/starship.toml.bak.$(date +%Y%m%d%H%M%S)"
            mv "${HOME}/.config/starship.toml" "${backup}"
            info "백업: starship.toml → ${backup}"
        fi
        stow -d "${DOTFILES_DIR}" -t "${HOME}" --ignore='\.DS_Store' starship
        ok "starship stow 완료"
    }

    # claude → ~/.claude
    mkdir -p "${HOME}/.claude"
    # claude 설정은 stow 대신 직접 복사 (디렉토리 구조가 다름)
    for f in settings.json CLAUDE.md; do
        if [ -f "${DOTFILES_DIR}/claude/${f}" ]; then
            if [ ! -f "${HOME}/.claude/${f}" ]; then
                cp "${DOTFILES_DIR}/claude/${f}" "${HOME}/.claude/${f}"
                ok "${f} → ~/.claude/${f}"
            else
                skip "${HOME}/.claude/${f} 이미 존재 — 건너뜀 (수동 병합 필요)"
            fi
        fi
    done
    # statusline.sh: settings.json 의 statusLine 이 가리키는 스크립트.
    # 이미 존재해도 repo 버전이 최신일 수 있으므로 매번 덮어씀.
    if [ -f "${DOTFILES_DIR}/claude/statusline.sh" ]; then
        cp "${DOTFILES_DIR}/claude/statusline.sh" "${HOME}/.claude/statusline.sh"
        chmod +x "${HOME}/.claude/statusline.sh"
        ok "statusline.sh → ~/.claude/statusline.sh"
    fi

    ok "심링크 완료"
}

# ─────────────────────────────────────────────
# oh-my-zsh 프레임워크 + 커뮤니티 플러그인
# ─────────────────────────────────────────────
install_oh_my_zsh() {
    # 프레임워크 본체
    if [ -d "${HOME}/.oh-my-zsh" ]; then
        skip "oh-my-zsh 이미 설치됨"
    else
        info "oh-my-zsh 설치 중..."
        # --unattended: 프롬프트 / chsh / 즉시 zsh 실행 모두 skip
        # --keep-zshrc: 기존 ~/.zshrc 보존 (이미 stow 로 심링크 만들어져 있음)
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc >/dev/null
        ok "oh-my-zsh 설치 완료"
    fi

    # 커뮤니티 플러그인 (.zshrc 의 plugins=(...) 가 참조)
    local custom_dir="${HOME}/.oh-my-zsh/custom/plugins"
    mkdir -p "$custom_dir"

    if [ -d "${custom_dir}/zsh-autosuggestions" ]; then
        skip "zsh-autosuggestions 이미 설치됨"
    else
        info "zsh-autosuggestions 설치 중..."
        git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions "${custom_dir}/zsh-autosuggestions"
        ok "zsh-autosuggestions 설치 완료"
    fi

    if [ -d "${custom_dir}/zsh-syntax-highlighting" ]; then
        skip "zsh-syntax-highlighting 이미 설치됨"
    else
        info "zsh-syntax-highlighting 설치 중..."
        git clone --depth 1 https://github.com/zsh-users/zsh-syntax-highlighting.git "${custom_dir}/zsh-syntax-highlighting"
        ok "zsh-syntax-highlighting 설치 완료"
    fi
}

# ─────────────────────────────────────────────
# TPM (Tmux Plugin Manager) 설치 + 선언된 플러그인 자동 설치
# ─────────────────────────────────────────────
install_tpm() {
    local tpm_dir="${HOME}/.config/tmux/plugins/tpm"
    if [ -d "$tpm_dir" ]; then
        skip "TPM 이미 설치됨"
    else
        info "TPM 설치 중..."
        mkdir -p "$(dirname "$tpm_dir")"
        git clone https://github.com/tmux-plugins/tpm "$tpm_dir"
        ok "TPM 설치 완료"
    fi

    # tmux.conf 에서 선언한 플러그인을 자동 설치 (멱등)
    if [ -x "${tpm_dir}/scripts/install_plugins.sh" ]; then
        info "tmux 플러그인 설치 중..."
        "${tpm_dir}/scripts/install_plugins.sh" >/dev/null 2>&1 || \
            warn "tmux 플러그인 설치 실패 — tmux 안에서 prefix + I 로 재시도"
        ok "tmux 플러그인 설치 완료"
    fi
}

# ─────────────────────────────────────────────
# 메인
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
    info "감지된 OS: ${os}"

    # OS별 패키지 설치
    case "$os" in
        macos)  source "${DOTFILES_DIR}/scripts/macos.sh"  ;;
        ubuntu) source "${DOTFILES_DIR}/scripts/ubuntu.sh" ;;
        centos) source "${DOTFILES_DIR}/scripts/centos.sh" ;;
    esac

    install_packages

    # 공통 설정
    link_configs
    install_oh_my_zsh
    install_tpm

    # Claude Code (npm 글로벌)
    if has_cmd claude; then
        skip "Claude Code CLI 이미 설치됨"
    else
        if has_cmd npm; then
            info "Claude Code CLI 설치 중..."
            npm install -g @anthropic-ai/claude-code
            ok "Claude Code 설치 완료 — 'claude' 로 인증하세요"
        else
            warn "npm 없음 — Claude Code 수동 설치 필요"
        fi
    fi

    echo ""
    ok "설치 완료!"
    echo ""
    info "다음 단계:"
    echo "  0. 기본 셸을 zsh 로: chsh -s \"\$(command -v zsh)\"  (root/sudo 권한 필요)"
    echo "  1. 터미널을 재시작하거나 source ~/.zshrc"
    echo "  2. nvim 실행 → lazy.nvim 이 플러그인 자동 설치"
    echo "  3. tmux 실행 → TPM 플러그인은 이미 설치됨 (prefix + I 는 재설치 용도)"
    echo "  4. claude 실행 → OAuth 인증"
    echo ""
}

main "$@"
