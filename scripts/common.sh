#!/usr/bin/env bash
# Shared utility functions for install scripts.

# ─────────────────────────────────────────────
# Logging
# ─────────────────────────────────────────────
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[0;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

info()  { echo -e "${BLUE}[INFO]${NC}  $*"; }
ok()    { echo -e "${GREEN}[OK]${NC}    $*"; }
warn()  { echo -e "${YELLOW}[SKIP]${NC}  $*"; }
skip()  { echo -e "${YELLOW}[SKIP]${NC}  $*"; }
error() { echo -e "${RED}[ERR]${NC}   $*" >&2; }

# ─────────────────────────────────────────────
# Check helpers
# ─────────────────────────────────────────────

# Does the command exist?
has_cmd() {
    command -v "$1" &>/dev/null
}

# Minimum-version check: version_gte "0.10.0" "0.9.5" → true
version_gte() {
    local required="$1"
    local current="$2"
    printf '%s\n%s' "$required" "$current" \
        | sort -V | head -n1 | grep -qx "$required"
}

# Extract Neovim version.
nvim_version() {
    nvim --version 2>/dev/null | head -1 | grep -oP 'v\K[0-9]+\.[0-9]+\.[0-9]+'
}

# Extract tmux version.
tmux_version() {
    tmux -V 2>/dev/null | grep -oP '[0-9]+\.[0-9a-z]+'
}

# ─────────────────────────────────────────────
# Stow helpers
# ─────────────────────────────────────────────
backup_and_stow() {
    local pkg="$1"
    local target="$2"
    local backup="${target}.bak.$(date +%Y%m%d%H%M%S)"

    if [ -e "$target" ]; then
        info "Backup: ${target} → ${backup}"
        mv "$target" "$backup"
    fi

    stow -d "${DOTFILES_DIR}" -t "$(dirname "$target")" --ignore='\.DS_Store' "$pkg"
    ok "${pkg} stow done"
}

# ─────────────────────────────────────────────
# Append-managed-block helpers (used for shell rc files)
# ─────────────────────────────────────────────
# Append a sourced managed block to a user rc file. The block is delimited by
# sentinel comments so subsequent installs can update it in place. The user's
# existing content is left untouched.
#
# Usage: append_managed_block <target_rc_file> <addon_file_to_source> <shell_kind>
#   shell_kind: "posix" or "zsh" (controls the [ -f ... ] && . syntax)
append_managed_block() {
    local target="$1"
    local addon="$2"
    local kind="${3:-posix}"
    local marker_begin="# >>> ai_dev_settings >>>"
    local marker_end="# <<< ai_dev_settings <<<"

    # Ensure the target file exists.
    if [ ! -e "$target" ]; then
        touch "$target"
    fi

    # If a managed block already exists, strip it so we can replace cleanly.
    if grep -qF "$marker_begin" "$target"; then
        # Portable in-place delete between markers (BSD + GNU sed safe).
        local tmp
        tmp=$(mktemp)
        awk -v b="$marker_begin" -v e="$marker_end" '
            $0 == b {skip=1; next}
            $0 == e {skip=0; next}
            !skip {print}
        ' "$target" > "$tmp"
        mv "$tmp" "$target"
        # Trim a trailing blank line if we left one behind.
        if [ -s "$target" ] && [ -z "$(tail -c1 "$target")" ]; then
            :
        fi
    fi

    # Append the block.
    {
        echo ""
        echo "$marker_begin"
        echo "# Managed by ai_dev_settings install.sh — edit the source file instead:"
        echo "#   ${addon}"
        if [ "$kind" = "zsh" ]; then
            echo "[ -f \"${addon}\" ] && source \"${addon}\""
        else
            echo "[ -f \"${addon}\" ] && . \"${addon}\""
        fi
        echo "$marker_end"
    } >> "$target"

    ok "Appended managed block to ${target}"
}

# ─────────────────────────────────────────────
# Conditional install wrappers
# ─────────────────────────────────────────────

# Run install_fn only when cmd is missing.
ensure_cmd() {
    local cmd="$1"
    local install_fn="$2"
    local label="${3:-$cmd}"

    if has_cmd "$cmd"; then
        skip "${label} already installed ($(command -v "$cmd"))"
    else
        info "Installing ${label}..."
        $install_fn
        if has_cmd "$cmd"; then
            ok "${label} installed"
        else
            error "${label} install failed"
            return 1
        fi
    fi
}

# Upgrade when cmd exists but version is below min_version.
ensure_version() {
    local cmd="$1"
    local min_version="$2"
    local get_version_fn="$3"
    local install_fn="$4"
    local label="${5:-$cmd}"

    if ! has_cmd "$cmd"; then
        info "Installing ${label}..."
        $install_fn
        ok "${label} installed"
        return
    fi

    local current
    current=$($get_version_fn)
    if version_gte "$min_version" "$current"; then
        skip "${label} ${current} ≥ ${min_version}"
    else
        warn "${label} ${current} < ${min_version} — upgrading..."
        $install_fn
        ok "${label} upgraded"
    fi
}
