# =============================================================================
# DistroZSH - 11-detect.zsh (distribution detection)
# =============================================================================
#
# Detects the running distribution from /etc/os-release using the standard
# fields (ID, ID_LIKE, NAME, PRETTY_NAME). Distributions are never hardcoded
# in the prompt: the closest registered parent is matched through ID first and
# ID_LIKE second, and unknown distributions fall back to a generic profile.
#
# =============================================================================

typeset -g DISTROZSH_OS_ID=""
typeset -g DISTROZSH_OS_ID_LIKE=""
typeset -g DISTROZSH_OS_NAME=""
typeset -g DISTROZSH_OS_PRETTY_NAME=""
typeset -g DISTROZSH_DISTRO_LABEL="generic"
typeset -g DISTROZSH_DETECTED_THEME="generic"
typeset -g DISTROZSH_PKG_MANAGER=""

# ---------------------------------------------------------------------------
# os-release registry (ID -> "label theme package-manager")
# ---------------------------------------------------------------------------
# The registry drives detection only. Distribution families (Fedora, Debian,
# Arch, SUSE) carry their own themes; unknown derivatives inherit the closest
# registered parent theme automatically.
# ---------------------------------------------------------------------------
typeset -gA _DISTROZSH_DISTRO_LABEL
typeset -gA _DISTROZSH_DISTRO_THEME
typeset -gA _DISTROZSH_DISTRO_PKG

_distrozsh_register_distro() { # id label theme package-manager
    _DISTROZSH_DISTRO_LABEL[$1]="$2"
    _DISTROZSH_DISTRO_THEME[$1]="$3"
    _DISTROZSH_DISTRO_PKG[$1]="$4"
}

# -- Official support --------------------------------------------------------
_distrozsh_register_distro fedora             fedora       fedora       dnf
_distrozsh_register_distro ubuntu             ubuntu       ubuntu       apt
_distrozsh_register_distro linuxmint          mint         mint         apt
_distrozsh_register_distro debian             debian       debian       apt
_distrozsh_register_distro kali               kali         kali         apt
_distrozsh_register_distro arch               arch         arch         pacman
_distrozsh_register_distro manjaro            manjaro      manjaro      pacman
_distrozsh_register_distro endeavouros        endeavour    endeavour    pacman
_distrozsh_register_distro opensuse-leap      opensuse     opensuse     zypper
_distrozsh_register_distro opensuse-tumbleweed opensuse    opensuse     zypper
_distrozsh_register_distro pop                pop          pop          apt
_distrozsh_register_distro elementary         elementary   elementary   apt
_distrozsh_register_distro zorin              zorin        zorin        apt
_distrozsh_register_distro rocky              rocky        rocky        dnf
_distrozsh_register_distro almalinux          almalinux    almalinux    dnf

# -- Community support (inherit the closest parent theme) --------------------
_distrozsh_register_distro nobara             nobara       fedora       dnf
_distrozsh_register_distro ultramarine        ultramarine  fedora       dnf
_distrozsh_register_distro bazzite            bazzite      fedora       dnf
_distrozsh_register_distro centos             centos       centos       dnf
_distrozsh_register_distro ol                 oracle       oracle       dnf
_distrozsh_register_distro garuda             garuda       arch         pacman
_distrozsh_register_distro cachyos            cachyos      arch         pacman
_distrozsh_register_distro artix              artix        artix        pacman
_distrozsh_register_distro mx                 mx           debian       apt
_distrozsh_register_distro parrot             parrot       parrot       apt
_distrozsh_register_distro neon               neon         neon         apt
_distrozsh_register_distro vanilla            vanilla      generic      apt
_distrozsh_register_distro peppermint         peppermint   peppermint   apt

# ---------------------------------------------------------------------------
# os-release parser
# ---------------------------------------------------------------------------
_distrozsh_parse_os_release() {
    local key value
    while IFS='=' read -r key value; do
        value="${value%\"}"
        value="${value#\"}"
        case "$key" in
            ID)          DISTROZSH_OS_ID="$value" ;;
            ID_LIKE)     DISTROZSH_OS_ID_LIKE="$value" ;;
            NAME)        DISTROZSH_OS_NAME="$value" ;;
            PRETTY_NAME) DISTROZSH_OS_PRETTY_NAME="$value" ;;
        esac
    done < /etc/os-release
}

# ---------------------------------------------------------------------------
# Detection
# ---------------------------------------------------------------------------
_distrozsh_detect() {
    _distrozsh_parse_os_release

    # 1. Exact ID match
    if [[ -n "$DISTROZSH_OS_ID" ]] && [[ -n "${_DISTROZSH_DISTRO_THEME[$DISTROZSH_OS_ID]:-}" ]]; then
        DISTROZSH_DISTRO_LABEL="${_DISTROZSH_DISTRO_LABEL[$DISTROZSH_OS_ID]}"
        DISTROZSH_DETECTED_THEME="${_DISTROZSH_DISTRO_THEME[$DISTROZSH_OS_ID]}"
        DISTROZSH_PKG_MANAGER="${_DISTROZSH_DISTRO_PKG[$DISTROZSH_OS_ID]}"
        return 0
    fi

    # 2. ID_LIKE match (fall back to the closest registered parent)
    local like
    for like in ${(s: :)DISTROZSH_OS_ID_LIKE}; do
        if [[ -n "${_DISTROZSH_DISTRO_THEME[$like]:-}" ]]; then
            DISTROZSH_DISTRO_LABEL="$DISTROZSH_OS_ID"
            DISTROZSH_DETECTED_THEME="${_DISTROZSH_DISTRO_THEME[$like]}"
            DISTROZSH_PKG_MANAGER="${_DISTROZSH_DISTRO_PKG[$like]}"
            return 0
        fi
    done

    # 3. Unknown distribution: graceful generic fallback
    DISTROZSH_DISTRO_LABEL="${DISTROZSH_OS_ID:-generic}"
    DISTROZSH_DETECTED_THEME="generic"
    DISTROZSH_PKG_MANAGER=""
    return 0
}

_distrozsh_detect
unset -f _distrozsh_register_distro _distrozsh_parse_os_release _distrozsh_detect
