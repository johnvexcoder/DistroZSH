# =============================================================================
# DistroZSH - config.zsh (user configuration)
# =============================================================================
#
# This file is YOURS. It is installed with sane defaults (everything below is
# commented out) and is never overwritten by re-running the installer.
#
# Uncomment the lines you want and restart zsh (or `exec zsh`).
#
# =============================================================================

# ---------------------------------------------------------------------------
# Theme
# ---------------------------------------------------------------------------
#   auto   - detect from the running distribution (default)
#   fedora, ubuntu, mint, debian, kali, arch, manjaro, endeavour, opensuse,
#   pop, elementary, zorin, rocky, almalinux, centos, oracle, artix, parrot,
#   neon, peppermint, generic
#   <anything else> - your own theme from ~/.config/distrozsh/themes/
# ---------------------------------------------------------------------------
# DISTROZSH_THEME=auto

# ---------------------------------------------------------------------------
# Layout
# ---------------------------------------------------------------------------
#   kali     - classic Kali-style two-line box (default)
#   oneline  - classic one-line
#   minimal  - path + prompt symbol only
#   compact  - compact user@host:path
# ---------------------------------------------------------------------------
# DISTROZSH_LAYOUT=kali

# ---------------------------------------------------------------------------
# Behaviour
# ---------------------------------------------------------------------------
# Print a blank line before every prompt (Kali-style breathing room).
# DISTROZSH_NEWLINE_BEFORE_PROMPT=no

# Set the terminal window title to user@host: dir.
# DISTROZSH_SET_TITLE=yes

# Location of the history database.
# DISTROZSH_HISTFILE=~/.zsh_history

# ---------------------------------------------------------------------------
# Command-not-found handling
# ---------------------------------------------------------------------------
#   auto    - distribution handler first, built-in fallback second (default)
#   distro  - only the distribution's own handler (pkgfile, command-not-found, ...)
#   builtin - always the built-in fallback (typo suggestions + package hint)
#   off     - stock zsh behaviour
# DISTROZSH_COMMAND_NOT_FOUND=auto

# Interactive spell correction for mistyped commands (zsh `setopt correct`).
# DISTROZSH_COMMAND_CORRECTION=yes
