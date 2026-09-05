# =============================================================================
# DistroZSH - 21-history.zsh (history)
# =============================================================================

HISTFILE="${DISTROZSH_HISTFILE:-$HOME/.zsh_history}"
HISTSIZE=1000
SAVEHIST=2000

setopt hist_expire_dups_first # delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt hist_ignore_dups       # ignore duplicated commands history list
setopt hist_ignore_space      # ignore commands that start with space
setopt hist_verify            # show command with history expansion to user before running it
setopt share_history          # append each command immediately and import new entries

# Note on share_history: commands are written to HISTFILE as soon as they are
# run, so `exec zsh` and parallel terminals no longer lose the most recent
# history (without it, history is only flushed on a clean shell exit, which
# exec never triggers).

# force zsh to show the complete history
alias history="history 0"
