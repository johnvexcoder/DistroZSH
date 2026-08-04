#!/usr/bin/env bash
#
# distro-detect.sh - DistroZSH distribution detection
#
# Standalone detection helper used by the installer, the preview renderer and
# CI. Reads /etc/os-release and prints the resolved DistroZSH profile.
#
# Usage:
#   ./distro-detect.sh              # print ID, ID_LIKE, NAME, PRETTY_NAME
#   ./distro-detect.sh --id         # print only the os-release ID
#   ./distro-detect.sh --label      # print the DistroZSH distribution label
#   ./distro-detect.sh --theme      # print the detected theme name
#   ./distro-detect.sh --pkg        # print the package manager (apt/dnf/pacman/zypper)
#   ./distro-detect.sh --json       # print everything as JSON
#
set -euo pipefail

# ---------------------------------------------------------------------------
# os-release parsing
# ---------------------------------------------------------------------------
ID=""
ID_LIKE=""
NAME=""
PRETTY_NAME=""
VERSION_ID=""

while IFS='=' read -r key value; do
    value="${value%\"}"
    value="${value#\"}"
    case "$key" in
        ID)          ID="$value" ;;
        ID_LIKE)     ID_LIKE="$value" ;;
        NAME)        NAME="$value" ;;
        PRETTY_NAME) PRETTY_NAME="$value" ;;
        VERSION_ID)  VERSION_ID="$value" ;;
    esac
done < /etc/os-release

# ---------------------------------------------------------------------------
# DistroZSH registry (ID -> "label theme package-manager")
# ---------------------------------------------------------------------------
declare -A LABEL THEME PKG

register() {
    LABEL[$1]="$2"
    THEME[$1]="$3"
    PKG[$1]="$4"
}

# Official support
register fedora             fedora       fedora       dnf
register ubuntu             ubuntu       ubuntu       apt
register linuxmint          mint         mint         apt
register debian             debian       debian       apt
register kali               kali         kali         apt
register arch               arch         arch         pacman
register manjaro            manjaro      manjaro      pacman
register endeavouros        endeavour    endeavour    pacman
register opensuse-leap      opensuse     opensuse     zypper
register opensuse-tumbleweed opensuse    opensuse     zypper
register pop                pop          pop          apt
register elementary         elementary   elementary   apt
register zorin              zorin        zorin        apt
register rocky              rocky        rocky        dnf
register almalinux          almalinux    almalinux    dnf

# Community support
register nobara             nobara       fedora       dnf
register ultramarine        ultramarine  fedora       dnf
register bazzite            bazzite      fedora       dnf
register centos             centos       centos       dnf
register ol                 oracle       oracle       dnf
register garuda             garuda       arch         pacman
register cachyos            cachyos      arch         pacman
register artix              artix        artix        pacman
register mx                 mx           debian       apt
register parrot             parrot       parrot       apt
register neon               neon         neon         apt
register vanilla            vanilla      generic      apt
register peppermint         peppermint   peppermint   apt

# ---------------------------------------------------------------------------
# Resolution
# ---------------------------------------------------------------------------
DETECTED_THEME="generic"
DETECTED_LABEL="${ID:-generic}"
DETECTED_PKG=""

if [[ -n "${THEME[$ID]:-}" ]]; then
    DETECTED_LABEL="${LABEL[$ID]}"
    DETECTED_THEME="${THEME[$ID]}"
    DETECTED_PKG="${PKG[$ID]}"
else
    for like in $ID_LIKE; do
        if [[ -n "${THEME[$like]:-}" ]]; then
            DETECTED_THEME="${THEME[$like]}"
            DETECTED_PKG="${PKG[$like]}"
            break
        fi
    done
fi

# ---------------------------------------------------------------------------
# Output
# ---------------------------------------------------------------------------
case "${1:-}" in
    --id)     printf '%s\n' "$ID" ;;
    --label)  printf '%s\n' "$DETECTED_LABEL" ;;
    --theme)  printf '%s\n' "$DETECTED_THEME" ;;
    --pkg)    printf '%s\n' "$DETECTED_PKG" ;;
    --json)
        printf '{"id":"%s","id_like":"%s","name":"%s","pretty_name":"%s","version_id":"%s","label":"%s","theme":"%s","pkg":"%s"}\n' \
            "$ID" "$ID_LIKE" "$NAME" "$PRETTY_NAME" "$VERSION_ID" \
            "$DETECTED_LABEL" "$DETECTED_THEME" "$DETECTED_PKG"
        ;;
    *)
        printf 'ID=%-20s NAME=%-20s PRETTY=%s\n' "$ID" "$NAME" "$PRETTY_NAME"
        printf 'label=%-12s theme=%-12s pkg=%s\n' "$DETECTED_LABEL" "$DETECTED_THEME" "${DETECTED_PKG:-unknown}"
        ;;
esac
