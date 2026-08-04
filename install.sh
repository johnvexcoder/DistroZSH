#!/usr/bin/env bash
#
# install.sh - DistroZSH installer
#
# DistroZSH: a lightweight, framework-free, cross-distribution ZSH experience
# inspired by native Linux distributions.
#
# Installs:
#   * zsh                        - the shell itself
#   * zsh-autosuggestions        - standalone plugin (distribution package)
#   * zsh-syntax-highlighting    - standalone plugin (distribution package)
#   * the DistroZSH engine       - ~/.config/distrozsh/ (config, themes, layouts)
#   * ~/.zshrc                   - the thin launcher (with backup)
#
# The installer is fully reversible:
#   * Any existing ~/.zshrc is backed up to ~/.zshrc.bak.<timestamp>.
#   * If you change your default shell to zsh, your previous shell is recorded
#     so uninstall.sh can restore it.
#   * Installation state is kept in ~/.config/distrozsh/.install-state.
#
# Supported package managers: dnf (Fedora, RHEL family), apt (Debian family),
# pacman (Arch family), zypper (openSUSE). RHEL-family plugins come from EPEL
# (enabled automatically); openSUSE plugins come from the OBS shells:zsh-users
# repository (added automatically).
#
# This script NEVER installs Oh My Zsh or any other ZSH framework.
#
# Usage:
#   ./install.sh                 # install packages, copy config, ask about shell
#   ./install.sh --shell         # also change the default shell to zsh (no prompt)
#   ./install.sh --no-shell      # do not change the default shell
#   ./install.sh --help          # show this help
#
set -euo pipefail

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------
PKG_LIST=(zsh zsh-autosuggestions zsh-syntax-highlighting)
MARKER="# DistroZSH:"
STATE_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/distrozsh"
STATE_FILE="$STATE_DIR/.install-state"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_ZSHRC="$SCRIPT_DIR/.zshrc"
ENGINE_ITEMS=(init.zsh zsh themes layouts scripts)

CHANGE_SHELL="ask"
for arg in "$@"; do
    case "$arg" in
        --shell)    CHANGE_SHELL="yes" ;;
        --no-shell) CHANGE_SHELL="no"  ;;
        -h|--help)
            sed -n '2,24p' "$0" | sed 's/^# \{0,1\}//'
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
run_sudo() {
    if [ "$(id -u)" -eq 0 ]; then
        "$@"
    else
        sudo "$@"
    fi
}

is_our_zshrc() {
    [ -f "$HOME/.zshrc" ] && grep -qF "$MARKER" "$HOME/.zshrc"
}

current_shell() {
    getent passwd "$(id -un)" | cut -d: -f7 || true
}

# ---------------------------------------------------------------------------
# Distribution / package manager detection
# ---------------------------------------------------------------------------
ID=""
ID_LIKE=""
VERSION_ID=""

while IFS='=' read -r key value; do
    value="${value%\"}"
    value="${value#\"}"
    case "$key" in
        ID)         ID="$value" ;;
        ID_LIKE)    ID_LIKE="$value" ;;
        VERSION_ID) VERSION_ID="$value" ;;
    esac
done < /etc/os-release

PM=""
NEED_EPEL="no"
EPEL_PKG="epel-release"
OBS_REPO_SUBDIR=""
OBS_DISTRO=""

detect_pm() {
    local haystack="$ID $ID_LIKE"
    case "$haystack" in
        *pacman*|*arch*|*manjaro*|*endeavouros*|*garuda*|*cachyos*|*artix*)
            PM="pacman"
            ;;
        *fedora*|*rhel*|*rocky*|*almalinux*|*centos*|*ol*|*nobara*|*ultramarine*|*bazzite*)
            PM="dnf"
            case "$ID" in
                rocky|almalinux|centos) NEED_EPEL="yes" ;;
                ol) NEED_EPEL="yes"; EPEL_PKG="oraclelinux-release-epel" ;;
            esac
            ;;
        *debian*|*ubuntu*|*kali*|*linuxmint*|*pop*|*elementary*|*zorin*|*mx*|*parrot*|*neon*|*vanilla*|*peppermint*)
            PM="apt"
            ;;
        *suse*)
            PM="zypper"
            if [ "$ID" = "opensuse-tumbleweed" ]; then
                OBS_REPO_SUBDIR="tumbleweed"
            elif [ "$ID" = "opensuse-leap" ]; then
                OBS_REPO_SUBDIR="$VERSION_ID"
            fi
            OBS_DISTRO="$ID"
            ;;
    esac
}
detect_pm

# ---------------------------------------------------------------------------
# 1. Detect ZSH
# ---------------------------------------------------------------------------
echo "==> Checking for ZSH"
if command -v zsh >/dev/null 2>&1; then
    echo "    zsh found: $(command -v zsh)"
else
    echo "    zsh not found; it will be installed below."
fi

# ---------------------------------------------------------------------------
# 2. Install required packages (zsh + the two standalone plugins)
# ---------------------------------------------------------------------------
if [ -z "$PM" ]; then
    echo "WARNING: package manager not recognized for \"$ID\"."
    echo "    Skipping package installation; install zsh, zsh-autosuggestions and"
    echo "    zsh-syntax-highlighting manually, then re-run this installer."
    echo
else
    echo "==> Package manager: $PM (distribution: ${ID:-unknown})"

    pkg_installed() {
        case "$PM" in
            apt)    dpkg-query -s "$1" >/dev/null 2>&1 ;;
            dnf)    rpm -q "$1" >/dev/null 2>&1 ;;
            pacman) pacman -Q "$1" >/dev/null 2>&1 ;;
            zypper) rpm -q "$1" >/dev/null 2>&1 ;;
        esac
    }

    echo "==> Installing packages: ${PKG_LIST[*]}"
    MISSING=()
    for pkg in "${PKG_LIST[@]}"; do
        pkg_installed "$pkg" || MISSING+=("$pkg")
    done

    if [ "${#MISSING[@]}" -eq 0 ]; then
        echo "    all packages already installed."
    else
        case "$PM" in
            dnf)
                if [ "$NEED_EPEL" = "yes" ]; then
                    echo "    enabling EPEL repository ($EPEL_PKG)..."
                    if ! rpm -q "$EPEL_PKG" >/dev/null 2>&1; then
                        run_sudo dnf install -y "$EPEL_PKG"
                    fi
                fi
                run_sudo dnf install -y "${MISSING[@]}"
                ;;
            apt)
                echo "    updating package lists..."
                run_sudo apt-get update -qq
                run_sudo apt-get install -y --no-install-recommends "${MISSING[@]}"
                ;;
            pacman)
                run_sudo pacman -S --noconfirm --needed "${MISSING[@]}"
                ;;
            zypper)
                if [ -n "$OBS_REPO_SUBDIR" ]; then
                    REPO_URL="https://download.opensuse.org/repositories/shells:zsh-users/$OBS_REPO_SUBDIR/shells:zsh-users.repo"
                    echo "    adding OBS shells:zsh-users repository for $OBS_DISTRO..."
                    if ! zypper repos --uri 2>/dev/null | grep -q "shells:zsh-users"; then
                        run_sudo zypper --non-interactive addrepo --refresh "$REPO_URL" shells:zsh-users
                    fi
                    run_sudo zypper --non-interactive refresh
                fi
                run_sudo zypper --non-interactive install -y "${MISSING[@]}"
                ;;
        esac
    fi
fi

# ---------------------------------------------------------------------------
# 3. Install the engine + launcher (with backup handler)
# ---------------------------------------------------------------------------
echo "==> Installing DistroZSH engine"

BACKUP=""
if [ -f "$HOME/.zshrc" ]; then
    if is_our_zshrc; then
        echo "    ~/.zshrc is already the DistroZSH launcher; leaving it as is."
    else
        BACKUP="$HOME/.zshrc.bak.$(date +%Y%m%d%H%M%S)"
        echo "    backing up existing ~/.zshrc -> $BACKUP"
        cp -p "$HOME/.zshrc" "$BACKUP"
    fi
fi

# zsh-autosuggestions needs ~/.cache for the completion dump (~/.cache/zcompdump)
mkdir -p "$HOME/.cache"
mkdir -p "$STATE_DIR"

# Engine files: copied fresh so upstream fixes win; user customizations in
# config.zsh, themes/ and layouts/ are preserved (cp merges, never deletes).
cp "$SCRIPT_DIR/init.zsh" "$STATE_DIR/init.zsh"
for item in "${ENGINE_ITEMS[@]}"; do
    if [ -e "$SCRIPT_DIR/$item" ]; then
        cp -r "$SCRIPT_DIR/$item" "$STATE_DIR/"
    fi
done

# User configuration: only installed once, never overwritten.
if [ ! -f "$STATE_DIR/config.zsh" ]; then
    cp "$SCRIPT_DIR/config.zsh" "$STATE_DIR/config.zsh"
    echo "    installed configuration template: $STATE_DIR/config.zsh"
else
    echo "    keeping existing configuration: $STATE_DIR/config.zsh"
fi

# Launcher
cp "$SRC_ZSHRC" "$HOME/.zshrc"
echo "    installed $HOME/.zshrc"
echo "    engine installed to $STATE_DIR"

# ---------------------------------------------------------------------------
# 4. Optionally change the default shell to ZSH (previous shell is recorded)
# ---------------------------------------------------------------------------
PREV_SHELL="$(current_shell)"

if [ "$CHANGE_SHELL" = "ask" ]; then
    printf "Change your default shell to zsh? [y/N] "
    read -r answer || true
    case "${answer,,}" in
        y|yes) CHANGE_SHELL="yes" ;;
        *)     CHANGE_SHELL="no" ;;
    esac
fi

if [ "$CHANGE_SHELL" = "yes" ]; then
    ZSH_BIN="$(command -v zsh)"
    echo "==> Changing default shell to $ZSH_BIN"
    if [ -n "$PREV_SHELL" ] && [ "$PREV_SHELL" != "$ZSH_BIN" ] && chsh -s "$ZSH_BIN" 2>/dev/null; then
        echo "    default shell changed. Log out and back in for it to take effect."
    else
        echo "    chsh failed (password required). Run it manually:"
        echo "        sudo usermod -s $ZSH_BIN \"$(id -un)\""
        echo "    or simply:"
        echo "        chsh -s $ZSH_BIN"
    fi
fi

# ---------------------------------------------------------------------------
# 5. Write installation state (used by uninstall.sh to restore everything)
# ---------------------------------------------------------------------------
{
    echo "PREV_SHELL=${PREV_SHELL:-}"
    echo "BACKUP=${BACKUP:-}"
    echo "INSTALLED_AT=$(date '+%Y-%m-%dT%H:%M:%S')"
    echo "ZSH_BIN=$(command -v zsh 2>/dev/null || true)"
} > "$STATE_FILE"

# ---------------------------------------------------------------------------
# 6. Done
# ---------------------------------------------------------------------------
cat <<EOF

Installation complete.

    * zsh and the standalone plugins are installed (via $PM).
    * ~/.zshrc (DistroZSH launcher) has been installed.
    * The engine lives in $STATE_DIR
    * A backup of your previous config was saved (if any).
    * State recorded in $STATE_FILE

Start a new terminal (or run: exec zsh) to activate the configuration.
Press Ctrl+P to toggle the prompt between two-line and one-line layouts.

Edit $STATE_DIR/config.zsh to change theme, layout and behaviour.
To remove everything and restore your previous setup: ./uninstall.sh

No ZSH framework (Oh My Zsh, Prezto, Zinit, Zplug, Powerlevel10k, ...) was
installed or required.
EOF
