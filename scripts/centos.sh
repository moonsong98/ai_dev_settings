#!/usr/bin/env bash
# CentOS 8 / Stream / RHEL package installation (dnf)

install_neovim_centos() {
    # The default CentOS 8 repos either lack neovim or ship an old version.
    # Fall back to EPEL, source build, or the upstream appimage.
    if has_cmd dnf; then
        sudo dnf install -y epel-release 2>/dev/null || true
        sudo dnf install -y neovim 2>/dev/null
    fi

    # If EPEL is too old, fall back to the appimage.
    if ! has_cmd nvim || ! version_gte "0.10.0" "$(nvim_version)"; then
        warn "EPEL neovim too old — installing appimage."
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
    # fd-find may be available via EPEL.
    sudo dnf install -y fd-find 2>/dev/null || {
        # Otherwise pull the GitHub release binary.
        warn "fd-find not in dnf — installing from GitHub."
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
        skip "fzf already installed"
        return
    fi
    git clone --depth 1 https://github.com/junegunn/fzf.git "${HOME}/.fzf"
    "${HOME}/.fzf/install" --bin --no-key-bindings --no-completion --no-update-rc
    sudo ln -sf "${HOME}/.fzf/bin/fzf" /usr/local/bin/fzf
}

install_starship_centos() {
    # Official install script (places a static binary in /usr/local/bin).
    curl -sS https://starship.rs/install.sh | sh -s -- -y
}

install_zsh_centos() {
    sudo dnf install -y zsh
}

install_jq_centos() {
    sudo dnf install -y jq
}

install_tree_sitter_centos() {
    # tree-sitter CLI isn't in dnf → grab the GitHub release binary.
    local ver="0.26.9"
    local url="https://github.com/tree-sitter/tree-sitter/releases/download/v${ver}/tree-sitter-linux-x64.gz"
    curl -fL "$url" -o /tmp/tree-sitter.gz
    gunzip -f /tmp/tree-sitter.gz
    chmod +x /tmp/tree-sitter
    sudo mv /tmp/tree-sitter /usr/local/bin/tree-sitter
}

install_build_deps_centos() {
    sudo dnf groupinstall -y "Development Tools" 2>/dev/null || true
    sudo dnf install -y git curl unzip
}

install_packages() {
    info "=== CentOS/RHEL package installation ==="

    # Enable EPEL.
    sudo dnf install -y epel-release 2>/dev/null || true

    # Build dependencies
    install_build_deps_centos

    # Core tools
    ensure_cmd "nvim"  install_neovim_centos  "Neovim"
    ensure_cmd "tmux"  install_tmux_centos    "tmux"
    ensure_cmd "node"  install_node_centos    "Node.js"
    ensure_cmd "stow"  install_stow_centos    "GNU Stow"
    ensure_cmd "zsh"   install_zsh_centos     "zsh"
    ensure_cmd "jq"    install_jq_centos      "jq"
    ensure_cmd "tree-sitter" install_tree_sitter_centos "tree-sitter CLI"

    # Search tools
    ensure_cmd "rg"    install_ripgrep_centos "ripgrep"
    ensure_cmd "fd"    install_fd_centos      "fd"
    ensure_cmd "fzf"   install_fzf_centos     "fzf"

    # Prompt
    ensure_cmd "starship" install_starship_centos "starship"

    ok "CentOS packages installed"
}
