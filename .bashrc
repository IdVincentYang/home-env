
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

    # more external oh-my-zsh themes: https://github.com/robbyrussell/oh-my-zsh/wiki/External-themes

}

function install-brew {
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    brew cask install shadowsocksx-ng
}

function install-brew-base {
    brew install autoconf automake git lrzsz p7zip stormssh tree vim wget you-get youtube-dl
    brew cask install apptrap java karabiner-elements keepassxc keyboard-maestro macvim openvanilla osxfuse
    #   depends osxfuse
    brew install ntfs-3g sshfs
    #   network tools
    brew install iperf3 iproute2mac
    #   need FQ
    # brew cask install go2shell
}

function install-brew-app {
    brew cask install androidtool aria2gui betterzipql gimp icefloor iffmpeg iina invisor-lite qlmarkdown
    # rdm virtualbox virtualbox-extension-pac
    #   game tools
    brew cask install openemu
}

function install-brew-dev {
    brew cask install beyond-compare gitkraken visual-studio-code wireshark
    #   C++ dev tools
    brew install cloc cmake the_silver_searcher
    #   java/android dev tools
    brew install ant jenv nvm
    brew cask install android-sdk android-studio
}

function install-brew-ql {
    # brew cask install provisionql qladdict qlcolorcode qldds qlgradle qlimagesize qlprettypatch
    # qlrest qlstephen qlvideo quicklook-csv quicklook-json quicklook-pat quicklookapk
    # quicklookase receiptquicklook webpquicklook
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

# Node NVM NPM config
function loadnvm() {
    source $(brew --prefix nvm)/nvm.sh
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
export ANDROID_SDK_ROOT=/usr/local/share/android-sdk
export ANDROID_HOME=${ANDROID_SDK_ROOT}
export PATH=${ANDROID_SDK_ROOT}/platform-tools:${PATH}

#   chromium source config
export PATH=~/github/Chromium/depot_tools:${PATH}

#export ANDROID_NDK_HOME="/usr/local/share/android-ndk"
#export USE_CCACHE=0
#export CCACHE_DIR=/Developer/ccache
#export NDK_CCACHE=/usr/local/bin/ccache

