# ~/.zprofile addon — zsh login shell.
# Sourced from your real ~/.zprofile via a managed block written by install.sh.

# Pull in the shared POSIX env so bash login and zsh login agree.
[ -f "$HOME/.profile" ] && . "$HOME/.profile"

# Obsidian (macOS GUI app — ignored on Linux).
[ -d "/Applications/Obsidian.app" ] && export PATH="$PATH:/Applications/Obsidian.app/Contents/MacOS"
