#!/usr/bin/env bash
# Ubuntu / Debian 패키지 설치 (apt)

install_neovim_ubuntu() {
    # 안정적인 최신 버전을 위해 PPA 사용
    sudo apt-get install -y software-properties-common
    sudo add-apt-repository -y ppa:neovim-ppa/stable
    sudo apt-get update
    sudo apt-get install -y neovim
}

install_tmux_ubuntu() {
    sudo apt-get install -y tmux
}

install_node_ubuntu() {
    # NodeSource LTS
    if [ ! -f /etc/apt/sources.list.d/nodesource.list ]; then
        curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
    fi
    sudo apt-get install -y nodejs
}

install_stow_ubuntu() {
    sudo apt-get install -y stow
}

install_ripgrep_ubuntu() {
    sudo apt-get install -y ripgrep
}

install_fd_ubuntu() {
    # Ubuntu에서 패키지명이 fd-find
    sudo apt-get install -y fd-find
    # fd-find는 fdfind로 설치됨 → fd 심링크
    if has_cmd fdfind && ! has_cmd fd; then
        sudo ln -sf "$(command -v fdfind)" /usr/local/bin/fd
    fi
}

install_fzf_ubuntu() {
    sudo apt-get install -y fzf
}

install_starship_ubuntu() {
    # 공식 install script (정적 바이너리를 /usr/local/bin 에 설치)
    curl -sS https://starship.rs/install.sh | sh -s -- -y
}

install_zsh_ubuntu() {
    sudo apt-get install -y zsh
}

install_jq_ubuntu() {
    sudo apt-get install -y jq
}

install_build_deps_ubuntu() {
    sudo apt-get install -y git curl unzip build-essential
}

install_packages() {
    info "=== Ubuntu 패키지 설치 ==="

    sudo apt-get update -qq

    # 빌드 의존성
    install_build_deps_ubuntu

    # 핵심 도구
    ensure_cmd "nvim"  install_neovim_ubuntu  "Neovim"
    ensure_cmd "tmux"  install_tmux_ubuntu    "tmux"
    ensure_cmd "node"  install_node_ubuntu    "Node.js"
    ensure_cmd "stow"  install_stow_ubuntu    "GNU Stow"
    ensure_cmd "zsh"   install_zsh_ubuntu     "zsh"
    ensure_cmd "jq"    install_jq_ubuntu      "jq"

    # 검색 도구
    ensure_cmd "rg"    install_ripgrep_ubuntu "ripgrep"
    ensure_cmd "fzf"   install_fzf_ubuntu     "fzf"

    # fd는 fdfind로 설치될 수 있으므로 별도 처리
    if has_cmd fd || has_cmd fdfind; then
        skip "fd 이미 설치됨"
    else
        install_fd_ubuntu
    fi

    # 프롬프트
    ensure_cmd "starship" install_starship_ubuntu "starship"

    ok "Ubuntu 패키지 설치 완료"
}
