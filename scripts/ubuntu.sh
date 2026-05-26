#!/usr/bin/env bash
# Ubuntu / Debian package installation (apt)

install_neovim_ubuntu() {
    # Use the stable PPA for a recent version.
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
    # On Ubuntu the package is named fd-find.
    sudo apt-get install -y fd-find
    # The binary is installed as fdfind — add an fd symlink.
    if has_cmd fdfind && ! has_cmd fd; then
        sudo ln -sf "$(command -v fdfind)" /usr/local/bin/fd
    fi
}

install_fzf_ubuntu() {
    sudo apt-get install -y fzf
}

install_starship_ubuntu() {
    # Official install script (places a static binary in /usr/local/bin).
    curl -sS https://starship.rs/install.sh | sh -s -- -y
}

install_zsh_ubuntu() {
    sudo apt-get install -y zsh
}

install_jq_ubuntu() {
    sudo apt-get install -y jq
}

install_tree_sitter_ubuntu() {
    # tree-sitter CLI isn't in apt → grab the GitHub release binary.
    local ver="0.26.9"
    local url="https://github.com/tree-sitter/tree-sitter/releases/download/v${ver}/tree-sitter-linux-x64.gz"
    curl -fL "$url" -o /tmp/tree-sitter.gz
    gunzip -f /tmp/tree-sitter.gz
    chmod +x /tmp/tree-sitter
    sudo mv /tmp/tree-sitter /usr/local/bin/tree-sitter
}

install_build_deps_ubuntu() {
    sudo apt-get install -y git curl unzip build-essential
}

install_packages() {
    info "=== Ubuntu package installation ==="

    sudo apt-get update -qq

    # Build dependencies
    install_build_deps_ubuntu

    # Core tools
    ensure_cmd "nvim"  install_neovim_ubuntu  "Neovim"
    ensure_cmd "tmux"  install_tmux_ubuntu    "tmux"
    ensure_cmd "node"  install_node_ubuntu    "Node.js"
    ensure_cmd "stow"  install_stow_ubuntu    "GNU Stow"
    ensure_cmd "zsh"   install_zsh_ubuntu     "zsh"
    ensure_cmd "jq"    install_jq_ubuntu      "jq"
    ensure_cmd "tree-sitter" install_tree_sitter_ubuntu "tree-sitter CLI"

    # Search tools
    ensure_cmd "rg"    install_ripgrep_ubuntu "ripgrep"
    ensure_cmd "fzf"   install_fzf_ubuntu     "fzf"

    # fd may be present under the fdfind name → handle separately.
    if has_cmd fd || has_cmd fdfind; then
        skip "fd already installed"
    else
        install_fd_ubuntu
    fi

    # Prompt
    ensure_cmd "starship" install_starship_ubuntu "starship"

    ok "Ubuntu packages installed"
}
