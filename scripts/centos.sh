#!/usr/bin/env bash
# CentOS 8 / Stream / RHEL 패키지 설치 (dnf)

install_neovim_centos() {
    # CentOS 8 기본 repo에는 neovim이 없거나 버전이 낮음
    # EPEL + 소스빌드 또는 appimage 사용
    if has_cmd dnf; then
        sudo dnf install -y epel-release 2>/dev/null || true
        sudo dnf install -y neovim 2>/dev/null
    fi

    # EPEL 버전이 너무 낮으면 appimage로 대체
    if ! has_cmd nvim || ! version_gte "0.10.0" "$(nvim_version)"; then
        warn "EPEL neovim 버전 부족 — appimage로 설치합니다."
        curl -fLo /tmp/nvim.appimage \
            https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage
        chmod u+x /tmp/nvim.appimage
        sudo mv /tmp/nvim.appimage /usr/local/bin/nvim
    fi
}

install_tmux_centos() {
    sudo dnf install -y tmux
}

install_node_centos() {
    if [ ! -f /etc/yum.repos.d/nodesource-*.repo ]; then
        curl -fsSL https://rpm.nodesource.com/setup_lts.x | sudo bash -
    fi
    sudo dnf install -y nodejs
}

install_stow_centos() {
    sudo dnf install -y stow
}

install_ripgrep_centos() {
    sudo dnf install -y ripgrep
}

install_fd_centos() {
    # fd-find 패키지가 EPEL에 있을 수 있음
    sudo dnf install -y fd-find 2>/dev/null || {
        # 없으면 GitHub 릴리스에서 설치
        warn "dnf에 fd-find 없음 — GitHub에서 설치합니다."
        local fd_version="10.2.0"
        curl -fLo /tmp/fd.tar.gz \
            "https://github.com/sharkdp/fd/releases/download/v${fd_version}/fd-v${fd_version}-x86_64-unknown-linux-musl.tar.gz"
        tar -xzf /tmp/fd.tar.gz -C /tmp
        sudo cp "/tmp/fd-v${fd_version}-x86_64-unknown-linux-musl/fd" /usr/local/bin/fd
        rm -rf /tmp/fd*
    }
}

install_fzf_centos() {
    if [ -d "${HOME}/.fzf" ]; then
        skip "fzf 이미 설치됨"
        return
    fi
    git clone --depth 1 https://github.com/junegunn/fzf.git "${HOME}/.fzf"
    "${HOME}/.fzf/install" --bin --no-key-bindings --no-completion --no-update-rc
    sudo ln -sf "${HOME}/.fzf/bin/fzf" /usr/local/bin/fzf
}

install_starship_centos() {
    # 공식 install script (정적 바이너리를 /usr/local/bin 에 설치)
    curl -sS https://starship.rs/install.sh | sh -s -- -y
}

install_zsh_centos() {
    sudo dnf install -y zsh
}

install_jq_centos() {
    sudo dnf install -y jq
}

install_build_deps_centos() {
    sudo dnf groupinstall -y "Development Tools" 2>/dev/null || true
    sudo dnf install -y git curl unzip
}

install_packages() {
    info "=== CentOS/RHEL 패키지 설치 ==="

    # EPEL 활성화
    sudo dnf install -y epel-release 2>/dev/null || true

    # 빌드 의존성
    install_build_deps_centos

    # 핵심 도구
    ensure_cmd "nvim"  install_neovim_centos  "Neovim"
    ensure_cmd "tmux"  install_tmux_centos    "tmux"
    ensure_cmd "node"  install_node_centos    "Node.js"
    ensure_cmd "stow"  install_stow_centos    "GNU Stow"
    ensure_cmd "zsh"   install_zsh_centos     "zsh"
    ensure_cmd "jq"    install_jq_centos      "jq"

    # 검색 도구
    ensure_cmd "rg"    install_ripgrep_centos "ripgrep"
    ensure_cmd "fd"    install_fd_centos      "fd"
    ensure_cmd "fzf"   install_fzf_centos     "fzf"

    # 프롬프트
    ensure_cmd "starship" install_starship_centos "starship"

    ok "CentOS 패키지 설치 완료"
}
