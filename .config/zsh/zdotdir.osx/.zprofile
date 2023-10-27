
eval $(/opt/homebrew/bin/brew shellenv)

source "${BASH_CFG}/alias"
source "${BASH_CFG}/alias.osx"

export __ZDOTLOADED="$__ZDOTLOADED\n$ZDOTDIR/.zprofile"
