#!/usr/bin/env bash
# 공통 유틸리티 함수

# ─────────────────────────────────────────────
# 로깅
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
# 체크 헬퍼
# ─────────────────────────────────────────────

# 커맨드 존재 여부
has_cmd() {
    command -v "$1" &>/dev/null
}

# 최소 버전 비교: version_gte "0.10.0" "0.9.5" → true
version_gte() {
    local required="$1"
    local current="$2"
    printf '%s\n%s' "$required" "$current" \
        | sort -V | head -n1 | grep -qx "$required"
}

# Neovim 버전 추출
nvim_version() {
    nvim --version 2>/dev/null | head -1 | grep -oP 'v\K[0-9]+\.[0-9]+\.[0-9]+'
}

# tmux 버전 추출
tmux_version() {
    tmux -V 2>/dev/null | grep -oP '[0-9]+\.[0-9a-z]+'
}

# ─────────────────────────────────────────────
# Stow 헬퍼
# ─────────────────────────────────────────────
backup_and_stow() {
    local pkg="$1"
    local target="$2"
    local backup="${target}.bak.$(date +%Y%m%d%H%M%S)"

    if [ -e "$target" ]; then
        info "백업: ${target} → ${backup}"
        mv "$target" "$backup"
    fi

    stow -d "${DOTFILES_DIR}" -t "$(dirname "$target")" --ignore='\.DS_Store' "$pkg"
    ok "${pkg} stow 완료"
}

# ─────────────────────────────────────────────
# 조건부 설치 래퍼
# ─────────────────────────────────────────────

# 커맨드가 없을 때만 설치 함수 실행
ensure_cmd() {
    local cmd="$1"
    local install_fn="$2"
    local label="${3:-$cmd}"

    if has_cmd "$cmd"; then
        skip "${label} 이미 설치됨 ($(command -v "$cmd"))"
    else
        info "${label} 설치 중..."
        $install_fn
        if has_cmd "$cmd"; then
            ok "${label} 설치 완료"
        else
            error "${label} 설치 실패"
            return 1
        fi
    fi
}

# 커맨드가 있지만 버전이 낮을 때 업그레이드
ensure_version() {
    local cmd="$1"
    local min_version="$2"
    local get_version_fn="$3"
    local install_fn="$4"
    local label="${5:-$cmd}"

    if ! has_cmd "$cmd"; then
        info "${label} 설치 중..."
        $install_fn
        ok "${label} 설치 완료"
        return
    fi

    local current
    current=$($get_version_fn)
    if version_gte "$min_version" "$current"; then
        skip "${label} ${current} ≥ ${min_version}"
    else
        warn "${label} ${current} < ${min_version} — 업그레이드 중..."
        $install_fn
        ok "${label} 업그레이드 완료"
    fi
}
