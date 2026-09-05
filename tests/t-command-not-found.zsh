#!/usr/bin/env zsh
#
# t-command-not-found.zsh - built-in command-not-found fallback.
#
# Sources zsh/26-command-not-found.zsh with a fixture $PATH in the sandbox and
# checks the behaviour of every DISTROZSH_COMMAND_NOT_FOUND mode.
#
set -u

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$REPO_DIR/tests/helpers.zsh"

CNF_MODULE="$REPO_DIR/zsh/26-command-not-found.zsh"
DISTROZSH_PKG_MANAGER="dnf"

TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/dzsh-test-cnf.XXXXXXXX")"
trap 'rm -rf "$TMP_DIR"' EXIT

mkdir -p "$TMP_DIR/bin"
for cmd_name in git globzilla great this that then; do
    printf '#!/bin/sh\n# %s\n' "$cmd_name" > "$TMP_DIR/bin/$cmd_name"
    chmod +x "$TMP_DIR/bin/$cmd_name"
done

# Give zsh a command hash containing the fixture binaries.
path=("$TMP_DIR/bin" $path)
rehash

# -- mode: builtin -----------------------------------------------------------
DISTROZSH_COMMAND_NOT_FOUND="builtin"
DISTROZSH_COMMAND_CORRECTION=yes      # exercise the '[' safe-path with correction on
source "$CNF_MODULE"

(( $+functions[command_not_found_handler] )) || t_fail "builtin: handler is defined"
out="$(command_not_found_handler gti 2>&1)"
rc=$?
t_eq "$rc" "127" "builtin: handler returns 127"
t_contains "$out" "command not found: gti" "builtin: prints the classic error"
t_contains "$out" "git" "builtin: suggests adjacent-transposition typo"
t_contains "$out" "sudo dnf install gti" "builtin: prints package-manager hint"
if [[ "$out" == *"bad output format"* ]]; then
    t_fail "builtin: no arithmetic/format errors for '[' on PATH"
fi

out="$(command_not_found_handler gobuster 2>&1)"
t_contains "$out" "gobuster" "builtin: no-suggestion path still prints the command"

# -- mode: off ---------------------------------------------------------------
unset -f command_not_found_handler 2>/dev/null || true
DISTROZSH_COMMAND_NOT_FOUND="off"
DISTROZSH_COMMAND_CORRECTION="no"
source "$CNF_MODULE"
if (( $+functions[command_not_found_handler])); then
    t_fail "off: leaves no handler behind"
else
    t_ok "off: leaves no handler behind"
fi

# -- mode: auto --------------------------------------------------------------
# A handler must always be present (distribution one, or the built-in
# fallback when the host ships none).
unset -f command_not_found_handler 2>/dev/null || true
DISTROZSH_COMMAND_NOT_FOUND="auto"
source "$CNF_MODULE"
t_true '(( $+functions[command_not_found_handler] ))' "auto: a handler is always installed"

t_pass