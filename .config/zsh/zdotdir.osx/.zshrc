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
# proxyset -s "socks5h://127.0.0.1:7890" "http://127.0.0.1:7890"

source "${ZSH_CFG}/zshrc"

source "${BASH_CFG}/alias"
source "${BASH_CFG}/alias.osx"

################################################################################
# command tools config begin:

# ffmpeg
# export FONTCONFIG_PATH=/usr/local/etc/fonts

# fzf config: https://github.com/junegunn/fzf.vim
if which fzf > /dev/null; then
    # https://github.com/junegunn/fzf/blob/master/README-VIM.md
    # https://zhuanlan.zhihu.com/p/41859976

    # fzf 参数详见 fzf -h
    # export FZF_COMPLETION_TRIGGER='**'
    # Options to fzf command
    export FZF_COMPLETION_OPTS='--border --info=inline'

    # if fd exists, set fd as fzf backend, instead the default find
    if which fd > /dev/null; then

        function fzfd {
            echo $@
        }
        export FZF_DEFAULT_COMMAND='fd --one-file-system --hidden'
        # use ctrl + t to search path under home
        export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND --no-ignore . $HOME"
        # use alt + c to change pwd under home
        export FZF_ALT_C_COMMAND="$FZF_DEFAULT_COMMAND --no-ignore --type d . $HOME"

        # - The first argument to the function ($1) is the base path to start traversal
        # - See the source code (completion.{bash,zsh}) for the details.
        _fzf_compgen_path() {
            # fd --hidden --no-ignore --follow --exclude ".git/" "$1"
            _P="$(realpath $1)"
            if [ "$_P" == "$HOME" ]; then
                # under home directory
                fd --one-file-system --no-ignore . "$1"
            else
                fd --one-file-system --hidden . "$1"
            fi
        }

        # Use fd to generate the list for directory completion
        _fzf_compgen_dir() {
            _P="$(realpath $1)"
            if [ "$_P" == "$HOME" ]; then
                # under home directory
                fd --one-file-system --no-ignore --type d . "$1"
            else
                fd --one-file-system --hidden --type d . "$1"
            fi
        }
    fi

    _PREVIEW_DEFAULT_OPTS="'
        ([[ -f {} ]] && (bat --color=always --style=numbers --line-range=:500 {} || cat {})) ||
        ([[ -d {} ]] && (tree -C {} || ls -la {})) ||
        (echo {} 2> /dev/null | head -200)
    '"
    export FZF_DEFAULT_OPTS="
        --bind 'ctrl-a:select-all'
        --bind 'ctrl-o:execute(open {+})'
        --bind 'ctrl-s:execute(code {+})'
        --bind 'ctrl-v:execute(echo {+} | xargs -o mvim)'
        --bind 'ctrl-y:execute-silent(echo -e {+} | pbcopy)+abort'
        --bind 'ctrl-/:change-preview-window(down|hidden|)'
        --color header:italic
        --header 'CTRL+-:preview,a:select all,o:open,s:VS,v:mvim,y:copy'
        --height 70%
        --info=inline
        --layout=reverse
        --multi
        --preview $_PREVIEW_DEFAULT_OPTS
    "
    export FZF_CTRL_T_OPTS="
        --bind 'ctrl-/:change-preview-window(down|hidden|)'
        --preview $_PREVIEW_DEFAULT_OPTS
    "
    export FZF_CTRL_R_OPTS="
        --bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'
        --bind 'ctrl-/:toggle-preview'
        --color header:italic
        --header 'Press CTRL-Y to copy command into clipboard'
        --preview 'echo {}' --preview-window up:3:hidden:wrap
    "
    # Set FZF_ALT_C_COMMAND to override the default command 'cd' export FZF_ALT_C_COMMAND=cd
    export FZF_ALT_C_OPTS="
        --preview 'tree {} || ls -la {}'
    "
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
