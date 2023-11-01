################################################################################
# "read" Usage: read -r [VAR]
#   -r causes the string to be interpreted "raw" (without considering backslash escapes)
#
# extension="${basename##*.}"
# filename="${basename%.*}"
################################################################################

# 导出二笔输入法码表路径: Path of ErBi
export PEB="${HOME}/Library/Application Support/OpenVanilla/UserData/TableBased/erbi.cin"

export no_proxy="localhost, 127.0.0.1, ::1"

if [ $VIM ]; then
        export PS1='[VIM]\h:\w\$ '
fi

# Setting terminal proxy via clash
source "${BASH_CFG}/proxy"
proxyset -s "socks5h://127.0.0.1:7890" "http://127.0.0.1:7890"

source "${ZSH_CFG}/zshrc"

source "${BASH_CFG}/alias"
source "${BASH_CFG}/alias.osx"

################################################################################
# command tools config begin:

# ffmpeg
# export FONTCONFIG_PATH=/usr/local/etc/fonts

# fzf config: https://github.com/junegunn/fzf.vim
if which fzf > /dev/null; then
    # https://zhuanlan.zhihu.com/p/41859976
    if which fd > /dev/null; then
        export FZF_DEFAULT_COMMAND='fd --type file'
    elif which ag > /dev/null; then
        export FZF_DEFAULT_COMMAND='ag -g ""'
    fi
    if [ ! -z "$FZF_DEFAULT_COMMAND" ]; then
        export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    fi
    # FZF_COMPLETION_TRIGGER: 默认 **<tab>
    # fzf 参数详见 fzf -h
    export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --preview '(highlight -O ansi {} || cat {}) 2> /dev/null | head -500'"
fi

# This loads nvm bash_completion
if which nvm > /dev/null; then
    [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"
fi

# go config
# export GOPATH=~/go/.path
# export GOBIN=~/go/.bin
# export PATH=${GOBIN}:${PATH}

# homebrew
if which brew > /dev/null ; then
    export HOMEBREW_GITHUB_API_TOKEN="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"
    export HOMEBREW_NO_AUTO_UPDATE=1
fi

# wine config(no use on apple silicon)
# Override wine default storage folder $XDG_DATA_HOME to it's sub dir wineprefixes/default
#export WINE_PREFIX_ROOT="${XDG_DATA_HOME}/wineprefixes"
#export WINEPREFIX="${WINE_PREFIX_ROOT}/default"
# If want change wine environment, can source "$BASH_CFG/wine" for helper function:
#   - winenv
#   - wine
# After MacOS 10.15, MacOS don't support 32 bit binary, but 32 bit wine includes in wine-stable yet.
#   So WINEARCH must be win64 and alias 32 bit binaries to 64 bit version.
#export WINEARCH=win64
#alias wine=wine64

# Command tools config end.
################################################################################

#   If not in Warp.app load some zsh plugins.

if [[ ! "$__CFBundleIdentifier" =~ "warp" ]]; then
    source ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
    source  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

export __ZDOTLOADED="$__ZDOTLOADED\n$ZDOTDIR/.zshrc"
