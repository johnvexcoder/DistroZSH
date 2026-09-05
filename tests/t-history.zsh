#!/usr/bin/env zsh
#
# t-history.zsh - history configuration sanity checks.
#
# Verifies the values/settings the engine installs; the interactive load/save
# behaviour itself is covered end-to-end by the real ~/.zshrc flow (loading
# works because HISTFILE is set before the first prompt, and saving survives
# `exec zsh` because share_history appends every command immediately).
#
set -u

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$REPO_DIR/tests/helpers.zsh"

HISTFILE_BACKUP="${HISTFILE:-}"
SAVEHIST_BACKUP="${SAVEHIST:-}"
HISTSIZE_BACKUP="${HISTSIZE:-}"
unset HISTFILE SAVEHIST HISTSIZE

TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/dzsh-test-history.XXXXXXXX")"
trap 'rm -rf "$TMP_DIR"' EXIT

HOME="$TMP_DIR"
DISTROZSH_HISTFILE="$HOME/.custom_history"
source "$REPO_DIR/zsh/21-history.zsh"

t_eq "$HISTFILE" "$DISTROZSH_HISTFILE" "HISTFILE honours DISTROZSH_HISTFILE"
t_eq "$HISTSIZE" "1000" "HISTSIZE is 1000"
t_eq "$SAVEHIST" "2000" "SAVEHIST is 2000"
t_true '[[ -o share_history ]]' "share_history is enabled (survives exec zsh)"

HISTFILE="$HISTFILE_BACKUP"
SAVEHIST="$SAVEHIST_BACKUP"
HISTSIZE="$HISTSIZE_BACKUP"

t_pass