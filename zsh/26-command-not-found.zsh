# =============================================================================
# DistroZSH - 26-command-not-found.zsh (command-not-found handling)
# =============================================================================
#
# Makes the classic
#
#     zsh: command not found: foobar
#
# dead end useful instead of a dead end. When you mistype a command (typo) or
# run something a package provides but is not installed, DistroZSH now gives
# you:
#
#   * the active distribution's own command-not-found handler whenever one is
#     available (Debian/Ubuntu command-not-found, Arch pkgfile, Fedora/RHEL
#     PackageKit, ...), because it knows the packages better than we ever will;
#   * otherwise a fast, native-ZSH fallback that:
#       - prints a clear one-line error (never a silent prompt),
#       - suggests close matches from $PATH ("Did you mean ... ?"),
#       - prints a package-manager hint so you can install the real thing;
#   * optional interactive command spell correction (`setopt correct`).
#
# Configuration (in $DISTROZSH_HOME/config.zsh):
#
#   DISTROZSH_COMMAND_NOT_FOUND=auto
#       auto     distribution handler first, built-in fallback second (default)
#       distro   only ever load the distribution's own handler
#       builtin  always use the built-in fallback
#       off      do nothing (stock zsh behaviour)
#
#   DISTROZSH_COMMAND_CORRECTION=yes
#       yes      enable zsh's interactive command spell correction
#       no       keep stock zsh behaviour
#
# No frameworks, no extra packages: every fallback feature is native ZSH.
#
# =============================================================================

# ---------------------------------------------------------------------------
# User configuration (defaults may be overridden in config.zsh)
# ---------------------------------------------------------------------------
: "${DISTROZSH_COMMAND_NOT_FOUND:=auto}"
: "${DISTROZSH_COMMAND_CORRECTION:=yes}"

# ---------------------------------------------------------------------------
# zsh built-in command spell correction (interactive y/n/e prompt)
# ---------------------------------------------------------------------------
if [[ "$DISTROZSH_COMMAND_CORRECTION" == "yes" ]]; then
    setopt correct
fi

# ---------------------------------------------------------------------------
# Levenshtein distance (native ZSH, only runs when a command is missing)
# ---------------------------------------------------------------------------
_distrozsh_cnf_levenshtein() { # a b -> distance
    local a="$1" b="$2"
    local m=${#a} n=${#b}
    local -a prev row
    local i j cost ins del sub
    prev=()
    prev[1]=0
    for ((j=1; j<=n; j++)); do
        prev[$((j+1))]=$j
    done
    for ((i=1; i<=m; i++)); do
        row=()
        row[1]=$i
        for ((j=1; j<=n; j++)); do
            cost=1
            [[ "${a:$((i-1)):1}" == "${b:$((j-1)):1}" ]] && cost=0
            del=$(( row[$j] + 1 ))
            ins=$(( prev[$((j+1))] + 1 ))
            sub=$(( prev[$j] + cost ))
            if (( del < ins )); then
                row[$((j+1))]=$(( del < sub ? del : sub ))
            else
                row[$((j+1))]=$(( ins < sub ? ins : sub ))
            fi
        done
        prev=("${row[@]}")
    done
    print -r -- "$(( prev[$((n+1))] ))"
}

# ---------------------------------------------------------------------------
# Adjacent-transposition test: is b equal to a with one neighbouring pair
# swapped? ("gti" vs "git", "taht" vs "that"). Levenshtein counts a swap as
# distance 2, but swapped letters are the most common real-world typo, so a
# one-swap difference is treated as a near match too.
# ---------------------------------------------------------------------------
_distrozsh_cnf_is_swap() { # a b
    local a="$1" b="$2" i
    (( ${#a} == ${#b} )) || return 1
    for (( i=0; i < ${#a}-1; i++ )); do
        if [[ "${a:0:$i}" == "${b:0:$i}" ]] \
            && [[ "${a:$i:1}" == "${b:$((i+1)):1}" ]] \
            && [[ "${a:$((i+1)):1}" == "${b:$i:1}" ]] \
            && [[ "${a:$((i+2))}" == "${b:$((i+2))}" ]]; then
            return 0
        fi
    done
    return 1
}

# ---------------------------------------------------------------------------
# Suggest close matches from $PATH (up to 5, same first letter, small edit
# distance). Returns a comma-separated list on $REPLY.
# ---------------------------------------------------------------------------
_distrozsh_cnf_suggest() { # command
    local cmd="$1"
    local len=${#cmd}
    (( len )) || return 1
    local threshold=2
    (( len <= 4 )) && threshold=1
    local -a words suggestions
    words=(${(k)commands})
    local candidate dist c1 cmd1
    cmd1="${cmd[1]}"
    for candidate in "${words[@]}"; do
        [[ "$candidate" == */* ]] && continue
        # Skip candidates that cannot be a close typo (different first letter).
        # Compare as strings: a bare '[' (the test utility) must never reach the
        # arithmetic evaluator, which mis-parses it as a subscript.
        c1="${candidate[1]}"
        [[ "$c1" == "$cmd1" ]] || continue
        if _distrozsh_cnf_is_swap "$cmd" "$candidate"; then
            suggestions+=("$candidate")
        else
            dist=$(_distrozsh_cnf_levenshtein "$cmd" "$candidate")
            if (( dist > 0 && dist <= threshold )); then
                suggestions+=("$candidate")
            else
                continue
            fi
        fi
        (( ${#suggestions} >= 5 )) && break
    done
    [[ -n "${suggestions[*]}" ]] || return 1
    print -r -- "${(j:, :)suggestions}"
}

# ---------------------------------------------------------------------------
# Package-manager hint: what would you install to get this command?
# ---------------------------------------------------------------------------
_distrozsh_cnf_pkg_tip() { # command
    local cmd="$1"
    [[ -z "$cmd" ]] && return 1
    case "${DISTROZSH_PKG_MANAGER:-}" in
        dnf)
            print -r -- "      Try: sudo dnf install $cmd"
            print -r -- "      or:  dnf provides \"*/bin/$cmd\""
            ;;
        apt)
            print -r -- "      Try: sudo apt install $cmd"
            print -r -- "      or:  apt-file search \"*/bin/$cmd\""
            ;;
        pacman)
            print -r -- "      Try: sudo pacman -S $cmd"
            print -r -- "      or:  pkgfile -b $cmd"
            ;;
        zypper)
            print -r -- "      Try: sudo zypper install $cmd"
            print -r -- "      or:  zypper search $cmd"
            ;;
        *) return 1 ;;
    esac
}

# ---------------------------------------------------------------------------
# Built-in fallback handler (used when no distribution handler exists)
# ---------------------------------------------------------------------------
_distrozsh_cnf_handler() {
    local cmd="${1:-}"
    local suggestions line tip
    print -r -- "zsh: command not found: $cmd" >&2
    if suggestions="$(_distrozsh_cnf_suggest "$cmd")"; then
        print -r -- "  Did you mean one of these?" >&2
        for line in "${(f)suggestions}"; do
            print -r -- "      $line" >&2
        done
    fi
    if tip="$(_distrozsh_cnf_pkg_tip "$cmd")"; then
        print -r -- "  Hint: this command may be provided by a package that is not installed." >&2
        print -r -- "$tip" >&2
    fi
    return 127
}

# ---------------------------------------------------------------------------
# Load the distribution's own command-not-found handler when available
# ---------------------------------------------------------------------------
_distrozsh_load_distro_cnf() {
    local candidate
    for candidate in \
        /etc/zsh_command_not_found \
        /usr/share/doc/pkgfile/command_not_found.zsh \
        /usr/share/zsh/site-functions/command-not-found \
        /usr/share/zsh/site-functions/command_not_found; do
        if [[ -r "$candidate" ]]; then
            source "$candidate"
            return 0
        fi
    done
    # Binary-only handlers: distributions that ship no zsh script but do ship
    # an executable (Fedora/RHEL PackageKit, Debian-family command-not-found).
    if [[ -x /usr/libexec/pk-command-not-found ]]; then
        command_not_found_handler() { /usr/libexec/pk-command-not-found "$*" }
        return 0
    fi
    if [[ -x /usr/lib/command-not-found ]]; then
        command_not_found_handler() { /usr/lib/command-not-found -- "$@" }
        return 0
    fi
    return 1
}

# ---------------------------------------------------------------------------
# Wire everything together per DISTROZSH_COMMAND_NOT_FOUND
# ---------------------------------------------------------------------------
case "$DISTROZSH_COMMAND_NOT_FOUND" in
    off)
        : ;;
    builtin)
        command_not_found_handler() { _distrozsh_cnf_handler "$@" }
        ;;
    distro)
        _distrozsh_load_distro_cnf
        ;;
    auto|*)
        _distrozsh_load_distro_cnf
        if (( ! $+functions[command_not_found_handler] )); then
            command_not_found_handler() { _distrozsh_cnf_handler "$@" }
        fi
        ;;
esac

# ---------------------------------------------------------------------------
# Cleanup
# ---------------------------------------------------------------------------
unset -f _distrozsh_load_distro_cnf