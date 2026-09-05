#!/usr/bin/env zsh
#
# t-distro-detect-sh.zsh - standalone scripts/distro-detect.sh (bash helper).
#
set -u

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$REPO_DIR/tests/helpers.zsh"

DISTRO_DETECT="$REPO_DIR/scripts/distro-detect.sh"
FIXTURES="$REPO_DIR/tests/fixtures"

proc() { # fixture args...
    local fixture="$1"
    shift
    DISTROZSH_OS_RELEASE_FILE="$FIXTURES/$fixture" bash "$DISTRO_DETECT" "$@"
}

t_eq "$(proc fedora.os-release --theme)"    "fedora"   "fedora --theme"
t_eq "$(proc fedora.os-release --pkg)"      "dnf"      "fedora --pkg"
t_eq "$(proc ubuntu.os-release --label)"    "ubuntu"   "ubuntu --label"
t_eq "$(proc arch.os-release --id)"         "arch"     "arch --id"
t_eq "$(proc derivative.os-release --theme)" "debian"  "derivative --theme (ID_LIKE fallback)"
t_eq "$(proc unknown.os-release --theme)"   "generic"  "unknown --theme (generic)"
t_eq "$(proc unknown.os-release --pkg)"     ""         "unknown --pkg (empty)"

json_output="$(proc ubuntu.os-release --json)"
t_contains "$json_output" '"id":"ubuntu"'  "ubuntu --json contains id"
t_contains "$json_output" '"theme":"ubuntu"' "ubuntu --json contains theme"
t_contains "$json_output" '"pkg":"apt"'      "ubuntu --json contains pkg"

t_pass