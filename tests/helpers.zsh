# =============================================================================
# tests/helpers.zsh - tiny assertion library for the DistroZSH test suite
#
# Every test file is executed standalone with `zsh -f` (no rc files) and must
# end with `t_pass` so the runner can rely on the exit status.
# =============================================================================

_FAIL=0

t_ok()   { print -r -- "  ok: $1" }
t_fail() { print -r -- "  FAIL: $1" >&2; _FAIL=1 }
t_skip() { print -r -- "  SKIP: $1" }

t_eq() { # actual expected label
    if [[ "$1" == "$2" ]]; then
        t_ok "$3"
    else
        t_fail "$3 (got '$1', want '$2')"
    fi
}

t_contains() { # haystack needle label
    if [[ "$1" == *"$2"* ]]; then
        t_ok "$3"
    else
        t_fail "$3 (output does not contain '$2')"
    fi
}

t_true() { # condition-string label
    if eval "$1"; then
        t_ok "$2"
    else
        t_fail "$2 ($1)"
    fi
}

t_pass() {
    if [[ "$_FAIL" -eq 0 ]]; then
        return 0
    fi
    return 1
}