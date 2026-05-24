# 셸 공통 env (PATH, brew shellenv, pyenv 등) 를 ~/.profile 에서 가져옴
# → bash login 도 같은 ~/.profile 을 source 하므로 환경 일관성 유지
[ -f "$HOME/.profile" ] && . "$HOME/.profile"

# Obsidian (Mac GUI app — Linux 에선 무시됨)
[ -d "/Applications/Obsidian.app" ] && export PATH="$PATH:/Applications/Obsidian.app/Contents/MacOS"
