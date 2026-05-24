# ~/.profile — POSIX 호환 셸 공통 환경 변수
# bash login (~/.bash_profile fallback) 과 zsh login (.zprofile 에서 source) 모두 읽음.
# 인터랙티브 전용 설정 (prompt, alias 등) 은 여기 두지 말 것 — 그건 .zshrc / .bashrc.

# ─── Homebrew (macOS Apple Silicon → Intel) ───
if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi

# ─── pyenv 경로 (init 은 .zshrc 의 인터랙티브 측에서) ───
if [ -d "$HOME/.pyenv" ]; then
    export PYENV_ROOT="$HOME/.pyenv"
    case ":$PATH:" in
        *":$PYENV_ROOT/bin:"*) ;;
        *) PATH="$PYENV_ROOT/bin:$PATH" ;;
    esac
fi

# ─── uv / 기타 user-local 바이너리 ───
if [ -d "$HOME/.local/bin" ]; then
    case ":$PATH:" in
        *":$HOME/.local/bin:"*) ;;
        *) PATH="$HOME/.local/bin:$PATH" ;;
    esac
fi

export PATH

# ─── 기본 에디터 (git, crontab, fc, ssh, … 가 모두 참조) ───
# nvim 우선, 없으면 vim, 그것도 없으면 vi
if command -v nvim >/dev/null 2>&1; then
    export EDITOR=nvim
elif command -v vim >/dev/null 2>&1; then
    export EDITOR=vim
else
    export EDITOR=vi
fi
export VISUAL="$EDITOR"
