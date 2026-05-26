#!/usr/bin/env bash
# macOS package installation (Homebrew)

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
    # macOS Catalina+ ships zsh by default, so has_cmd is normally true and
    # this function is never called. Used only when an explicit brew-zsh
    # (latest version) is required.
    brew install zsh
}

install_jq_mac() {
    brew install jq
}

install_tree_sitter_mac() {
    brew install tree-sitter-cli
}

install_packages() {
    info "=== macOS package installation ==="

    # Homebrew
    ensure_cmd "brew" install_homebrew "Homebrew"

    # Core tools
    ensure_cmd "nvim"  install_neovim_mac  "Neovim"
    ensure_cmd "tmux"  install_tmux_mac    "tmux"
    ensure_cmd "node"  install_node_mac    "Node.js"
    ensure_cmd "stow"  install_stow_mac    "GNU Stow"
    ensure_cmd "zsh"   install_zsh_mac     "zsh"
    ensure_cmd "jq"    install_jq_mac      "jq"
    ensure_cmd "tree-sitter" install_tree_sitter_mac "tree-sitter CLI"

    # Search tools (used by Neovim telescope, etc.)
    ensure_cmd "rg"    install_ripgrep_mac "ripgrep"
    ensure_cmd "fd"    install_fd_mac      "fd"
    ensure_cmd "fzf"   install_fzf_mac     "fzf"

    # Prompt
    ensure_cmd "starship" install_starship_mac "starship"

    ok "macOS packages installed"
}
