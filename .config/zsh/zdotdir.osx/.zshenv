### [Startup/Shutdown Files](https://zsh.sourceforge.io/Doc/Release/Files.html#index-ZDOTDIR_002c-use-of)
#
#   Commands are first read from /etc/zshenv, then read from $ZDOTDIR/.zshenv.
# If the shell is a login shell, commands are read from /etc/zprofile and then $ZDOTDIR/.zprofile.
# Then, if the shell is interactive, commands are read from /etc/zshrc and then $ZDOTDIR/.zshrc.
# Finally, if the shell is a login shell, /etc/zlogin and $ZDOTDIR/.zlogin are read.
#
#   When a login shell exits, the files $ZDOTDIR/.zlogout and then /etc/zlogout are read.

if [ -z "${__ZDOTLOADED}" ]; then
    ### Tweak zsh shell env
    # Disable Terminal app's per session save/restore mechanism(/etc/zshrc_Apple_Terminal)
    export SHELL_SESSIONS_DISABLE=1

    # Tweak terminal settings
    export LANG=en_US.UTF-8

    # Define home env variables
    export BASH_CFG="$HOME/.config/bash"
    export ZSH_CFG="$HOME/.config/zsh"

    # Define XDG like system dirs
    source "${BASH_CFG}/xdg_dirs"

    # set variable __ZDOTLOADED for dot file load track
    export __ZDOTLOADED="$__ZDOTLOADED\n$ZDOTDIR/.zshenv"
fi
