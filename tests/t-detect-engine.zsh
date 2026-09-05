#!/usr/bin/env zsh
#
# t-detect-engine.zsh - distribution detection (zsh engine module).
#
# Exercises zsh/11-detect.zsh against annotated os-release fixtures. Note:
# `local` at top level is legal in zsh scripts (they run in an implicit
# function scope) -- but keep the fixtures looped through a function anyway
# for clarity.
#
set -u

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$REPO_DIR/tests/helpers.zsh"

check() { # fixture expected_theme expected_pkg expected_label expected_id
    local fixture="$1" want_theme="$2" want_pkg="$3" want_label="$4" want_id="$5"
    DISTROZSH_OS_RELEASE_FILE="$REPO_DIR/tests/fixtures/$fixture"
    source "$REPO_DIR/zsh/11-detect.zsh"

    t_eq "$DISTROZSH_DETECTED_THEME" "$want_theme" "$fixture: theme"
    t_eq "$DISTROZSH_PKG_MANAGER" "$want_pkg" "$fixture: package manager"
    t_eq "$DISTROZSH_DISTRO_LABEL" "$want_label" "$fixture: label"
    t_eq "$DISTROZSH_OS_ID" "$want_id" "$fixture: os id"
}

check fedora.os-release    fedora dnf      fedora  fedora
check ubuntu.os-release    ubuntu apt      ubuntu  ubuntu
check arch.os-release      arch   pacman   arch    arch
check opensuse.os-release  opensuse zypper opensuse opensuse-leap
check derivative.os-release debian apt     mydistro mydistro
check unknown.os-release   generic ""      myunknown myunknown

# An explicit fixture with no os-release at all must still reset cleanly to
# the generic fallback rather than crashing.
DISTROZSH_OS_RELEASE_FILE="$REPO_DIR/tests/fixtures/missing.os-release"
source "$REPO_DIR/zsh/11-detect.zsh"
t_eq "$DISTROZSH_DETECTED_THEME" "generic" "missing file: generic fallback"

t_pass