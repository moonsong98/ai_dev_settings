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

    # nvim → ~/.config/nvim (stow 패키지 안에 .config/nvim/ 구조)
    stow -d "${DOTFILES_DIR}" -t "${HOME}" --ignore='\.DS_Store' nvim 2>/dev/null || {
        warn "nvim stow 충돌 — 기존 설정을 백업합니다."
        backup_and_stow "nvim" "${HOME}/.config/nvim"
    }

    # tmux → ~/.config/tmux
    stow -d "${DOTFILES_DIR}" -t "${HOME}" --ignore='\.DS_Store' tmux 2>/dev/null || {
        warn "tmux stow 충돌 — 기존 설정을 백업합니다."
        backup_and_stow "tmux" "${HOME}/.config/tmux"
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

    ok "심링크 완료"
}

# ─────────────────────────────────────────────
# TPM (Tmux Plugin Manager) 설치
# ─────────────────────────────────────────────
install_tpm() {
    local tpm_dir="${HOME}/.tmux/plugins/tpm"
    if [ -d "$tpm_dir" ]; then
        skip "TPM 이미 설치됨"
        return
    fi
    info "TPM 설치 중..."
    git clone https://github.com/tmux-plugins/tpm "$tpm_dir"
    ok "TPM 설치 완료 — tmux 실행 후 prefix + I 로 플러그인 설치"
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
    echo "  1. 터미널을 재시작하거나 source ~/.bashrc (또는 ~/.zshrc)"
    echo "  2. nvim 실행 → lazy.nvim이 자동으로 플러그인 설치"
    echo "  3. tmux 실행 → prefix(C-a) + I 로 TPM 플러그인 설치"
    echo "  4. claude 실행 → OAuth 인증"
    echo ""
}

main "$@"
