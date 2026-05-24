#!/usr/bin/env bash
# macOS 패키지 설치 (Homebrew)

install_homebrew() {
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

install_neovim_mac() {
    brew install neovim
}

install_tmux_mac() {
    brew install tmux
}

install_node_mac() {
    brew install node
}

install_stow_mac() {
    brew install stow
}

install_ripgrep_mac() {
    brew install ripgrep
}

install_fd_mac() {
    brew install fd
}

install_fzf_mac() {
    brew install fzf
}

install_starship_mac() {
    brew install starship
}

install_zsh_mac() {
    # macOS Catalina+ 는 기본 셸이 zsh 라 보통 has_cmd 가 true → 이 함수 호출 안 됨.
    # 명시적으로 brew zsh 가 필요한 경우 (최신 버전) 만 사용됨.
    brew install zsh
}

install_jq_mac() {
    brew install jq
}

install_tree_sitter_mac() {
    brew install tree-sitter-cli
}

install_packages() {
    info "=== macOS 패키지 설치 ==="

    # Homebrew
    ensure_cmd "brew" install_homebrew "Homebrew"

    # 핵심 도구
    ensure_cmd "nvim"  install_neovim_mac  "Neovim"
    ensure_cmd "tmux"  install_tmux_mac    "tmux"
    ensure_cmd "node"  install_node_mac    "Node.js"
    ensure_cmd "stow"  install_stow_mac    "GNU Stow"
    ensure_cmd "zsh"   install_zsh_mac     "zsh"
    ensure_cmd "jq"    install_jq_mac      "jq"
    ensure_cmd "tree-sitter" install_tree_sitter_mac "tree-sitter CLI"

    # 검색 도구 (Neovim telescope 등에 필요)
    ensure_cmd "rg"    install_ripgrep_mac "ripgrep"
    ensure_cmd "fd"    install_fd_mac      "fd"
    ensure_cmd "fzf"   install_fzf_mac     "fzf"

    # 프롬프트
    ensure_cmd "starship" install_starship_mac "starship"

    ok "macOS 패키지 설치 완료"
}
