
function _try_git_clone_to() {
     REPO_URL="$1"
     DEST_DIR="$2"
     if [ -z ${REPO_URL} ] || [ -z ${DEST_DIR} ]; then
         echo "ERROR: _try_git_clone_to: invalid paremater"
         return
     fi
     if [ -e ${DEST_DIR} ]; then
         echo "WARNING: _try_git_clone_to: dest dir already exists[${DEST_DIR}]"
         return
     fi
 
     git clone $3 $4 $5 $6 $7 $8 $9 "${REPO_URL}" "${DEST_DIR}"
}

function install-ohmyzsh {
    ZSH_DIR=~/.oh-my-zsh
    if [ ! -e ${ZSH_DIR} ]; then
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
    fi
    if [ -d ${ZSH_DIR} ]; then
        cp -r ~/.home-env/zsh-themes/* ${ZSH_DIR}/themes/
    fi
}

function install-terminal-themes {
    # _try_git_clone_to git://github.com/altercation/solarized.git ~/.solarized --depth=1

    # _try_git_clone_to https://github.com/lysyi3m/macos-terminal-themes.git ~/.macos-terminal-themes --depth=1

    # ref: https://www.jianshu.com/p/60a11f762f62
    POWERLINE_FONTS_DIR=~/.powerline-fonts
    _try_git_clone_to https://github.com/powerline/fonts.git ${POWERLINE_FONTS_DIR} --depth=1
    pushd ${POWERLINE_FONTS_DIR} > /dev/null
    ./install.sh
    popd > /dev/null
}

function install-ohmyzsh-plugins {
    _try_git_clone_to https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    _try_git_clone_to https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

    # more external oh-my-zsh themes: https://github.com/robbyrussell/oh-my-zsh/wiki/External-themes

}

function install-brew {
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    brew cask install shadowsocksx-ng
}

function install-brew-base {
    brew install autoconf automake fd ffmpeg fzf git lrzsz p7zip stormssh tree vim wget you-get youtube-dl
    brew cask install apptrap caffeine oracle-jdk karabiner-elements keepassxc keyboard-maestro macvim openvanilla osxfuse
    brew cask install suspicious-package hammerspoon
    #   vim doc chinese version: https://sourceforge.net/projects/vimcdoc/

    #   depends osxfuse
    brew install ntfs-3g sshfs
    #   network tools
    brew install iperf3 iproute2mac
    brew cask install charles wireshark
    #   need FQ
    # brew cask install go2shell
}

function install-brew-app {
    brew cask install androidtool aria2gui gimp google-chrome icefloor iina invisor-lite
    brew cask install xmind
    # rdm virtualbox virtualbox-extension-pac
    #   game tools
    brew cask install openemu
}

function install-brew-dev {
    brew cask install beyond-compare gitkraken visual-studio-code 
    #   C++ dev tools
    brew install cloc cmake the_silver_searcher
    #   java/android dev tools
    brew install ant jenv nvm
    brew cask install android-studio quicklook-json
}

function install-brew-ql {
    brew cask install  qlmarkdown qlvideo
    # brew cask install provisionql qladdict qlcolorcode qldds qlgradle qlimagesize qlprettypatch
    # qlrest qlstephen quicklook-csv quicklook-pat quicklookapk
    # quicklookase receiptquicklook webpquicklook
}

function tweak-osx {
    defaults write com.apple.appstore ShowDebugMenu -bool true
}

# custom bin path
export PATH=~/bin:${PATH}

if [ -f ~/.bashalias ]; then
    . ~/.bashalias
fi

# home brew
export HOMEBREW_NO_AUTO_UPDATE=1
# ffmpeg
# export FONTCONFIG_PATH=/usr/local/etc/fonts

# fzf config
if [ -f `which fzf` ]; then
    # https://zhuanlan.zhihu.com/p/41859976
    if [ -f `which fd` ]; then
        export FZF_DEFAULT_COMMAND='fd --type file'
    elif [ -f `which ag` ]; then
        export FZF_DEFAULT_COMMAND='ag -g ""'
    fi
    if [ ! -z $FZF_DEFAULT_COMMAND ]; then
        export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    fi
    # FZF_COMPLETION_TRIGGER: 默认 **<tab>
    # fzf 参数详见 fzf -h
    export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --preview '(highlight -O ansi {} || cat {}) 2> /dev/null | head -500'"
fi

# Node NVM NPM config
function loadnvm() {
    # Set NVM_DIR if it isn't already defined
    [[ -z "$NVM_DIR" ]] && export NVM_DIR="$HOME/.nvm"

    # Load nvm if it exists
    NVM_SH=$(brew --prefix nvm)/nvm.sh
    [[ -f "$NVM_SH" ]] && source "$NVM_SH"
}

function hfs() {
    [[ ! -f "$(which node)" ]] && loadnvm
    if [ ! -f "$(which node)" ]; then
        echo "invalid nodejs env"
	return 1
    fi

    [[ ! -f "$(which http-server)" ]] && npm install http-server -g
    if [ ! -f "$(which http-server)" ]; then
        echo "can't find http-server bin"
	return 2
    fi

    http-server $@
}

export NVM_NODEJS_ORG_MIRROR=http://npm.taobao.org/mirrors/node
alias npm='npm --registry=https://registry.npm.taobao.org '

# JVM config
if which jenv > /dev/null; then eval "$(jenv init -)"; fi

# python config
export PATH=~/Library/Python/2.7/bin:${PATH}

# go config
export GOPATH=~/go/.path
export GOBIN=~/go/.bin
export PATH=${GOBIN}:${PATH}

# android sdk config
export ANDROID_SDK_ROOT=~/Library/Android/sdk
export ANDROID_HOME=${ANDROID_SDK_ROOT}
export PATH=${ANDROID_SDK_ROOT}/platform-tools:${PATH}

# android ndk config
export ANDROID_NDK_HOME=/usr/local/share/android-ndk
#export NDK_CCACHE=/usr/local/bin/ccache

#   chromium source config
export PATH=~/github/Chromium/depot_tools:${PATH}

#export USE_CCACHE=0
#export CCACHE_DIR=/Developer/ccache

