# =============================================================================
# DistroZSH - 20-options.zsh (shell options)
# =============================================================================

setopt autocd              # change directory just by typing its name
setopt interactivecomments # allow comments in interactive mode
setopt magicequalsubst     # enable filename expansion for arguments of the form 'anything=expression'
setopt nonomatch           # hide error message if there is no match for the pattern
setopt notify              # report the status of background jobs immediately
setopt numericglobsort     # sort filenames numerically when it makes sense
setopt promptsubst         # enable command substitution in prompt

# Do not consider certain characters part of a word (for word jumps)
WORDCHARS='_-'

# Hide the EOL marker ('%') shown when output does not end with a newline
PROMPT_EOL_MARK=""
