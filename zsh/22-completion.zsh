# =============================================================================
# DistroZSH - 22-completion.zsh (completion)
# =============================================================================
#
# Native ZSH completion with:
#   * case-insensitive matching
#   * colored completion
#   * menu selection with TAB
#   * completion caching (dump written to ~/.cache/zcompdump)
#   * verbose descriptions and group names
#
# This block mirrors the stock Kali/Debian configuration (byte-for-byte
# compatible behaviour) so the experience feels native on Debian-family
# distributions.
#
# =============================================================================

# Load the completion system. The dump file is written to ~/.cache/zcompdump.
autoload -Uz compinit
compinit -d "$HOME/.cache/zcompdump"

zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' rehash true
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'
