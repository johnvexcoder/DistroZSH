#!/usr/bin/env bash
#
# tests/run.sh - DistroZSH test runner.
#
# Runs every tests/t-*.zsh test file in a fresh zsh (no rc files). A test
# file passes when it exits 0. Any assertion failure prints "FAIL:" on stderr
# and the file exits non-zero.
#
# Usage:
#   ./tests/run.sh              # run the whole suite
#   ./tests/run.sh t-syntax.zsh # run a single test file
#
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT" || exit 1

TESTS=("$@")
if [ "${#TESTS[@]}" -eq 0 ]; then
    mapfile -t TESTS < <(printf '%s\n' "$ROOT"/tests/t-*.zsh | xargs -n1 basename)
fi

FAILURES=0
RAN=0

for t in "${TESTS[@]}"; do
    file="$ROOT/tests/$t"
    if [ ! -f "$file" ]; then
        printf '[ SKIP] %s (not found)\n' "$t"
        continue
    fi
    RAN=$((RAN + 1))
    printf '[ RUN ] %s\n' "$t"
    # 0.5s between jobs lets the machine breathe during the preview matrix.
    if zsh -f -- "$file"; then
        printf '[ PASS] %s\n' "$t"
    else
        printf '[ FAIL] %s\n' "$t" >&2
        FAILURES=$((FAILURES + 1))
    fi
done

printf '\n%d test file(s) run, %d failed.\n' "$RAN" "$FAILURES"
if [ "$FAILURES" -eq 0 ] && [ "$RAN" -gt 0 ]; then
    exit 0
fi
exit 1