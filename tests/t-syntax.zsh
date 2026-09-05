#!/usr/bin/env zsh
#
# t-syntax.zsh - every shell file must pass a syntax check (mirrors CI).
#
set -u

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$REPO_DIR/tests/helpers.zsh"

cd "$REPO_DIR" || exit 1

zsh -n init.zsh        || t_fail "zsh -n init.zsh"
zsh -n .zshrc          || t_fail "zsh -n .zshrc"
zsh -n config.zsh      || t_fail "zsh -n config.zsh"

local f
for f in zsh/*.zsh themes/*.zsh layouts/*.zsh scripts/*.zsh(N); do
    zsh -n "$f" || t_fail "zsh -n $f"
done

for f in install.sh uninstall.sh scripts/*.sh tests/run.sh; do
    if [[ -e "$f" ]]; then
        bash -n "$f" || t_fail "bash -n $f"
    fi
done

t_pass