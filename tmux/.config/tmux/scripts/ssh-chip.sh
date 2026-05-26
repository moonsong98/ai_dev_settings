#!/usr/bin/env bash
# Renders an "SSH user@host" or "local" chip for the tmux status bar.
# Detection: SSH_CONNECTION / SSH_TTY is set by sshd at login; tmux preserves
# these via the `update-environment` directive in tmux.conf.

set -eu

host=$(hostname -s 2>/dev/null || hostname)
user=${USER:-$(id -un)}

if [ -n "${SSH_CONNECTION:-}" ] || [ -n "${SSH_TTY:-}" ]; then
    # Red, bold — be loud about being remote so destructive commands give pause.
    printf '#[fg=red,bold] SSH %s@%s #[default]' "$user" "$host"
else
    printf '#[fg=brightblack] local %s #[default]' "$host"
fi
