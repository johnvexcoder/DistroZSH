#!/usr/bin/env bash
#
# uninstall.sh - DistroZSH uninstaller
#
# Restores the system to its pre-install state:
#   * Removes the DistroZSH ~/.zshrc launcher.
#   * Restores the backed-up ~/.zshrc (newest ~/.zshrc.bak.<timestamp>).
#   * Restores the previous default shell recorded at install time.
#   * Backs up your DistroZSH config.zsh, then removes ~/.config/distrozsh.
#
# This script does NOT:
#   * uninstall zsh
#   * uninstall zsh-autosuggestions or zsh-syntax-highlighting
#
# Usage:
#   ./uninstall.sh               # restore everything
#   ./uninstall.sh --keep-shell  # restore config but leave the shell as-is
#   ./uninstall.sh --help        # show this help
#
set -euo pipefail

MARKER="# DistroZSH:"
STATE_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/distrozsh"
STATE_FILE="$STATE_DIR/.install-state"

KEEP_SHELL="no"
for arg in "$@"; do
    case "$arg" in
        --keep-shell) KEEP_SHELL="yes" ;;
        -h|--help)
            sed -n '2,20p' "$0" | sed 's/^# \{0,1\}//'
            exit 0
            ;;
        *)
            echo "Unknown argument: $arg" >&2
            exit 1
            ;;
    esac
done

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
is_our_zshrc() {
    [ -f "$HOME/.zshrc" ] && grep -qF "$MARKER" "$HOME/.zshrc"
}

newest_backup() {
    find "$HOME" -maxdepth 1 -name '.zshrc.bak.*' -printf '%T@ %p\n' 2>/dev/null \
        | sort -rn \
        | head -n1 \
        | cut -d' ' -f2-
}

current_shell() {
    getent passwd "$(id -un)" | cut -d: -f7 || true
}

read_state() {
    if [ -f "$STATE_FILE" ]; then
        # shellcheck disable=SC1090
        . "$STATE_FILE"
    fi
}

run_sudo() {
    if [ "$(id -u)" -eq 0 ]; then
        "$@"
    else
        sudo "$@"
    fi
}

# ---------------------------------------------------------------------------
# 1. Load recorded state
# ---------------------------------------------------------------------------
read_state
PREV_SHELL="${PREV_SHELL:-}"

# ---------------------------------------------------------------------------
# 2. Restore the configuration
# ---------------------------------------------------------------------------
if is_our_zshrc; then
    BACKUP="$(newest_backup)"

    if [ -n "$BACKUP" ] && [ -f "$BACKUP" ]; then
        echo "==> Restoring previous configuration from: $BACKUP"
        cp -p "$BACKUP" "$HOME/.zshrc"
        echo "    restored $HOME/.zshrc"
    else
        echo "==> No backup found; removing $HOME/.zshrc"
        rm -f "$HOME/.zshrc"
    fi
else
    echo "==> ~/.zshrc is not the DistroZSH launcher; leaving it untouched."
fi

# ---------------------------------------------------------------------------
# 3. Restore the previous default shell (if it was changed at install time)
# ---------------------------------------------------------------------------
if [ "$KEEP_SHELL" = "no" ] && [ -n "$PREV_SHELL" ]; then
    ZSH_BIN="$(command -v zsh 2>/dev/null || true)"
    CURRENT="$(current_shell)"

    if [ -n "$ZSH_BIN" ] && [ "$PREV_SHELL" = "$ZSH_BIN" ]; then
        echo "==> Default shell is still zsh; nothing to restore."
    elif [ -n "$CURRENT" ] && [ -n "$PREV_SHELL" ] && [ "$CURRENT" != "$PREV_SHELL" ]; then
        echo "==> Restoring default shell to: $PREV_SHELL"
        if chsh -s "$PREV_SHELL" 2>/dev/null; then
            echo "    default shell restored. Log out and back in for it to take effect."
        else
            echo "    chsh failed (password required). Restore it manually:"
            echo "        sudo usermod -s $PREV_SHELL \"$(id -un)\""
        fi
    else
        echo "==> Default shell is unchanged; nothing to restore."
    fi
fi

# ---------------------------------------------------------------------------
# 4. Preserve user configuration, then remove the engine
# ---------------------------------------------------------------------------
if [ -f "$STATE_DIR/config.zsh" ]; then
    CONFIG_BACKUP="$HOME/.config/distrozsh.config.zsh.bak.$(date +%Y%m%d%H%M%S)"
    cp -p "$STATE_DIR/config.zsh" "$CONFIG_BACKUP"
    echo "==> Saved your DistroZSH configuration to: $CONFIG_BACKUP"
fi

if [ -d "$STATE_DIR" ]; then
    rm -rf "$STATE_DIR"
    echo "==> Removed DistroZSH engine: $STATE_DIR"
fi

# ---------------------------------------------------------------------------
# 5. Done
# ---------------------------------------------------------------------------
cat <<EOF

Uninstallation complete.

    * The DistroZSH launcher has been removed.
    * Your previous ~/.zshrc backup was restored (if one existed).
    * Your previous default shell was restored (if it was changed).
    * Your DistroZSH config.zsh was saved (if one existed).
    * zsh, zsh-autosuggestions and zsh-syntax-highlighting were left installed.

Start a new terminal (or run: source ~/.zshrc) for the restored config to take effect.
EOF
