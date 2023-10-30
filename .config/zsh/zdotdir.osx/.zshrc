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

################################################################################
# command tools config begin:

# android sdk path
if [ -d ~/Library/Android/sdk ]; then
    export ANDROID_SDK_ROOT=~/Library/Android/sdk
    export ANDROID_HOME=${ANDROID_SDK_ROOT}
    export PATH=${ANDROID_SDK_ROOT}/platform-tools:${PATH}
fi

# ffmpeg
# export FONTCONFIG_PATH=/usr/local/etc/fonts

# fzf config: https://github.com/junegunn/fzf.vim
if which fzf > /dev/null ; then
    # https://zhuanlan.zhihu.com/p/41859976
    if [ -f `which fd` ]; then
        export FZF_DEFAULT_COMMAND='fd --type file'
    elif [ -f `which ag` ]; then
        export FZF_DEFAULT_COMMAND='ag -g ""'
    fi
    if [ ! -z "$FZF_DEFAULT_COMMAND" ]; then
        export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    fi
    # FZF_COMPLETION_TRIGGER: 默认 **<tab>
    # fzf 参数详见 fzf -h
    export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --preview '(highlight -O ansi {} || cat {}) 2> /dev/null | head -500'"
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

# Java VM bin path
if which jenv > /dev/null; then
    export PATH="$HOME/.jenv/bin:$PATH"
    eval "$(jenv init -)"
fi

# pyenv config
if which pyenv > /dev/null; then
    export PYENV_ROOT="${XDG_DATA_HOME}/pyenv"
    eval "$(pyenv init -)"
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
