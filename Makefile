# ============================================================================
# DistroZSH - developer Makefile
# ============================================================================
# Common development tasks. All commands run from the repository root and
# never require a DistroZSH installation.
#
#   make test          run the full test suite (tests/run.sh)
#   make lint          shellcheck the bash scripts
#   make syntax        zsh -n / bash -n syntax check every script
#   make check         lint + syntax + tests (everything CI runs)
#   make preview       render one prompt (feed THEME=/ LAYOUT=)
#   make screenshots   regenerate the PNG screenshot matrix
#   make install       install on the current machine (package manager)
#   make uninstall     fully reverse an installation
#   make clean         remove generated output
# ============================================================================

THEME ?= fedora
LAYOUT ?= kali
PREFIX ?= /tmp/distrozsh

.PHONY: all check lint syntax test preview screenshots install uninstall clean help

all: check

## check : everything CI runs: lint + syntax + tests
check: lint syntax test
	@printf 'All checks passed.\n'

## lint : ShellCheck on all bash scripts (severity=warning)
lint:
	@command -v shellcheck >/dev/null 2>&1 || { printf 'shellcheck not installed; run: sudo dnf install shellcheck (or apt/pacman/zypper)\n' >&2; exit 1; }
	shellcheck --shell=bash --severity=warning install.sh uninstall.sh scripts/distro-detect.sh scripts/make-screenshots.sh

## syntax : zsh -n and bash -n on every shell file
syntax:
	@command -v zsh >/dev/null 2>&1 || { printf 'zsh not installed.\n' >&2; exit 1; }
	zsh -n init.zsh .zshrc config.zsh
	zsh -n zsh/*.zsh themes/*.zsh layouts/*.zsh scripts/preview.sh
	@bash -n install.sh uninstall.sh scripts/distro-detect.sh scripts/make-screenshots.sh tests/run.sh

## test : run the test suite (tests/run.sh)
test:
	@./tests/run.sh

## preview : render one prompt (THEME=<name> LAYOUT=<name>)
preview:
	@./scripts/preview.sh "$(THEME)" "$(LAYOUT)"

## screenshots : regenerate the PNG screenshot matrix
screenshots:
	@./scripts/make-screenshots.sh

## install : install on the current machine (with --no-shell for safety)
install:
	@./install.sh --no-shell

## uninstall : fully reverse an installation (keeps shell by default)
uninstall:
	@./uninstall.sh --keep-shell

## clean : remove generated/preview artifacts
clean:
	@rm -rf "$(PREFIX)"
	@find . -type d -name __pycache__ -prune -exec rm -rf {} +
	@printf 'Cleaned.\n'

help:
	@sed -n '1,40p' Makefile | sed -n 's/^## /  /p' | head -40