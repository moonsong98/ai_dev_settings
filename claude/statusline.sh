#!/usr/bin/env bash
# Claude Code custom status line
# Reads session JSON on stdin, prints one-line HUD with ANSI colors.
#
# Fields used (see Claude Code docs):
#   model.display_name, effort.level,
#   cost.total_cost_usd, cost.total_lines_added, cost.total_lines_removed,
#   cost.total_duration_ms,
#   context_window.used_percentage,
#   rate_limits.five_hour.used_percentage   (Pro/Max 전용 — Enterprise/API 면 자동 미표시)
#
# 각 세그먼트는 해당 필드가 statusLine 입력에 없으면 자동으로 빠짐 (optional).

# macOS 기본 bash 3.2 가 빈 배열 + set -u 와 안 친해서 strict 모드 안 켬
input="$(cat)"

# jq 가 없으면 안내만 출력하고 종료 (statusLine 자체는 깨지지 않게)
if ! command -v jq >/dev/null 2>&1; then
    printf 'statusline.sh: jq missing — install jq for HUD'
    exit 0
fi

get() { printf '%s' "$input" | jq -r "$1 // empty" 2>/dev/null; }

# ─── ANSI ───
DIM=$'\033[2m'
RESET=$'\033[0m'
CYAN=$'\033[36m'
GREEN=$'\033[32m'
YELLOW=$'\033[33m'
RED=$'\033[31m'
MAGENTA=$'\033[35m'

# ─── 추출 ───
model="$(get '.model.display_name')"
effort="$(get '.effort.level')"
cost_usd="$(get '.cost.total_cost_usd')"
lines_added="$(get '.cost.total_lines_added')"
lines_removed="$(get '.cost.total_lines_removed')"
duration_ms="$(get '.cost.total_duration_ms')"
ctx_pct="$(get '.context_window.used_percentage')"
rate_5h="$(get '.rate_limits.five_hour.used_percentage')"

# ─── 헬퍼 ───
fmt_duration_ms() {
    local ms="$1"
    [ -z "$ms" ] && return
    local s=$(( ms / 1000 ))
    local m=$(( s / 60 ))
    s=$(( s % 60 ))
    if [ "$m" -gt 0 ]; then
        printf '%dm%02ds' "$m" "$s"
    else
        printf '%ds' "$s"
    fi
}

pct_color() {
    local pct="$1"
    pct="${pct%.*}"   # int part
    if   [ "$pct" -ge 80 ]; then printf '%s' "$RED"
    elif [ "$pct" -ge 50 ]; then printf '%s' "$YELLOW"
    else                         printf '%s' "$DIM"
    fi
}

# ─── 세그먼트 빌드 ───
seg=()

# 모델 (짧게)
[ -n "$model" ] && seg+=("${CYAN}${model}${RESET}")

# effort (색 코딩)
if [ -n "$effort" ]; then
    case "$effort" in
        low)         ec="$DIM" ;;
        medium)      ec="$GREEN" ;;
        high)        ec="$YELLOW" ;;
        xhigh|max)   ec="$RED" ;;
        *)           ec="$RESET" ;;
    esac
    seg+=("${ec}effort:${effort}${RESET}")
fi

# 비용
if [ -n "$cost_usd" ]; then
    cost_fmt="$(printf '%.3f' "$cost_usd" 2>/dev/null || echo "$cost_usd")"
    # 0.000 이면 표시 안 함
    if [ "$cost_fmt" != "0.000" ]; then
        seg+=("${YELLOW}\$${cost_fmt}${RESET}")
    fi
fi

# 라인 변경
la="${lines_added:-0}"
lr="${lines_removed:-0}"
if [ "$la" -gt 0 ] 2>/dev/null || [ "$lr" -gt 0 ] 2>/dev/null; then
    seg+=("${GREEN}+${la}${RESET}/${RED}-${lr}${RESET}")
fi

# 컨텍스트 사용률
if [ -n "$ctx_pct" ]; then
    pct_int="${ctx_pct%.*}"
    color="$(pct_color "$ctx_pct")"
    seg+=("${color}ctx ${pct_int}%${RESET}")
fi

# 5h rate limit
if [ -n "$rate_5h" ]; then
    pct_int="${rate_5h%.*}"
    color="$(pct_color "$rate_5h")"
    seg+=("${color}5h ${pct_int}%${RESET}")
fi

# 누적 시간
if [ -n "$duration_ms" ]; then
    dur="$(fmt_duration_ms "$duration_ms")"
    [ -n "$dur" ] && seg+=("${DIM}${dur}${RESET}")
fi

# ─── join with ❖ ───
SEP="${DIM} ❖ ${RESET}"
out=""
for i in "${!seg[@]}"; do
    if [ "$i" -gt 0 ]; then
        out+="$SEP"
    fi
    out+="${seg[$i]}"
done

printf '%b' "$out"
