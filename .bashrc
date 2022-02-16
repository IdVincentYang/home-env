################################################################################
# "read" Usage: read -r [VAR]
#   -r causes the string to be interpreted "raw" (without considering backslash escapes)
#
# extension="${basename##*.}"
# filename="${basename%.*}"
################################################################################

function ensure() {
    echo "Ensure cmd: $@"
    while : ; do
        $@
        [ $? -eq 0 ] && break
    done
    terminal-notifier -title "Execute CMD Complete!" -message "$@"
}

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
    #   homepage: https://brew.sh/
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    #   tray: for FQ
    brew install clashx
    #   app: homebrew GUI
    brew install cakebrew
}

function install-brew-base {
    brew install autoconf automake fd ffmpeg fzf git lrzsz p7zip stormssh tree vim watch wget you-get youtube-dl

    #   service with control panel:
    #       remove related files when remove app form /Applications folder
    brew install apptrap
    #   screensaver: Mac screen saver
    # brew install aerial
    #   tray: easily block os to sleep
    brew install caffeine
    #   Finder extensions: add button in toolbar to open termial
    brew install go2shell
    #   service with tray:
    #       auto-tools program with lua. for key-shortcuts configure, config under ~/.local/hammerspoon/
    brew install hammerspoon
    #   tray: enhance date tray icon's feature
    brew install itsycal
    #   app: tweak keyboard functions. eg: map right CMD to CMD+OPT+CTRL+SHIFT
    brew install karabiner-elements
    #   app: private passwords database
    brew install keepassxc
    #   app: key-shortcuts macro maker, replaced by hammerspoon
    # brew install keyboard-maestro
    #   app: vim doc chinese version: https://sourceforge.net/projects/vimcdoc/
    brew install macvim
    #   IME: for erbi, which db under ~/.local/erbi
    brew install openvanilla

    brew install oracle-jdk
    #   app: macOS Installer Packages(PKG) file viewer
    brew install suspicious-package
    #   3rd filesystem supported, osxfuse is base, but has been deprecated
    # brew install osxfuse ntfs-3g sshfs

    #   network tools
    brew install iperf3 iproute2mac
    brew install charles wireshark
}

function install-brew-app {
    brew install aria2gui gimp google-chrome icefloor

    ### devices apps
    #   cmd: connect android device via usb for device control
    brew install scrcpy
    #   app: connect android device via wifi and usb for device control
    brew install soduto
    #   tray: disable intel cpu's boost feature for save power
    #       usage: sudo /Applications/Turbo\ Boost\ Switcher.app/Contents/MacOS/Turbo\ Boost\ Switcher
    brew install turbo-boost-switcher
    #   app: vm ware, replaced by VMWare
    # brew install rdm virtualbox virtualbox-extension-pac

    ### media apps
    brew install iina invisor-lite macx-youtube-downloader media-converter
    ### game tools
    brew install openemu
    ### wine apps
    brew install wine-stable
}

function install-brew-dev {
    ### design tools
    brew install xmind

    ### coding tools
    #   cmd: code searching tool, usage: ag
    #       doc: https://github.com/ggreer/the_silver_searcher/wiki/Advanced-Usage
    brew install the_silver_searcher
    #   app: for file compare
    #       reset tral version: rm "/Users/$(whoami)/Library/Application Support/Beyond Compare/registry.dat"
    brew install beyond-compare
    #   cmd: count source lines
    brew install cloc
    #   cmd: Archive a repository with all its submodules.
    brew install git-archive-all
    #   app: git GUI
    brew install smartgit

    ### C++ dev tools
    brew install cmake

    ### java dev tools
    brew install ant
    brew install jenv

    ### java/android dev tools
    brew install android-studio
    brew install apktool

    ### javascript dev tools
    brew install nvm
    brew install visual-studio-code
}

function install-brew-ql {
    brew install  qlmarkdown qlvideo webpquicklook quicklook-json qlimagesize mdimagesizemdimporter
    # brew install provisionql qladdict qlcolorcode qldds qlgradle qlprettypatch
    # qlrest qlstephen quicklook-csv quicklook-pat quicklookapk
    # quicklookase receiptquicklook
}

function tweak-osx {
    defaults write com.apple.appstore ShowDebugMenu -bool true
    # 隐藏窗口显示半透明效果
    defaults write com.apple.Dock showhidden -bool true
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

#   chromium source config
export PATH=~/github/Chromium/depot_tools:${PATH}

# wine config
# winetricks src: https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks
# winetricks variable doc: https://github.com/Winetricks/winetricks/wiki
export XDG_DATA_HOME=/Users/yangws/.local/share/wineprefixes
export WINEARCH=win32
function winenv() {
    if [ $# = 0 ]; then
        unset WINEPREFIX
        unset WINARCH
    else
        export WINEPREFIX=$XDG_DATA_HOME/$1
        if [ $# -gt 1 ]; then
            export WINEARCH=win$2
        fi
    fi
    #   if WINEPREFIX dir not exit, try make it or tip exist dirs
    if [ ! -d $WINEPREFIX ]; then
        echo  "WINEPREFIX directory not exists yet, do you want create it [y/n]?"
        read -r _YN
        case $_YN in
            [Yy]* )
                mkdir $WINEPREFIX
                if [ -d $WINEPREFIX ]; then
                    wineboot
                    winecfg
                else
                    echo "Failure to create WINEPREFIX folder: $WINEPREFIX"
                fi
                ;;
            [Nn]* )
                echo "Please use valid dir as below:"
                ls $XDG_DATA_HOME
                ;;
        esac
    fi
}
function winepack() {
    if [ $# = 0 ]; then
        echo "Please input exe file absolute path and args!"
    elif [ ! -f $1 ]; then
        echo "Invalid exe file path!"
    else
        _BASE_NAME="$(basename "${1}")"
        _APP_NAME="${_BASE_NAME%.*}"
        _APP_BUNDLE="${_APP_NAME}.app"
        _CONTENT_DIR="${_APP_BUNDLE}/Contents"

        if [ -e "${_APP_BUNDLE}" ]; then
            echo "${PWD}/${_APP_BUNDLE} already exists :("
        else
            mkdir -p "${_CONTENT_DIR}"/MacOS
            # create sh
            _SH_PATH="${_CONTENT_DIR}/MacOS/${_APP_NAME}"
            touch "$_SH_PATH"
            echo "#!/bin/bash" > "$_SH_PATH"
            echo "WINEPREFIX=$WINEPREFIX" >> "$_SH_PATH"
            echo "WINEARCH=$WINEARCH" >> "$_SH_PATH"
            echo "wine $@" >>  "$_SH_PATH"
            chmod +x "$_SH_PATH"
            #create plist
            _PLIST="${_CONTENT_DIR}/Info.plist"
            touch "$_PLIST"
            echo '<?xml version="1.0" encoding="UTF-8"?>' > "$_PLIST"
            echo '<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">' >> "$_PLIST"
            echo '<plist version="1.0">' >> "$_PLIST"
            echo '<dict>' >> "$_PLIST"
            echo '  <key>CFBundleExecutable</key>' >> "$_PLIST"
            echo "    <string>${_APP_NAME}</string>" >> "$_PLIST"
            echo '  </dict>' >> "$_PLIST"
            echo '</plist>' >> "$_PLIST"

            echo "${_APP_BUNDLE} packed success"
        fi
    fi
}

#export USE_CCACHE=0
#export CCACHE_DIR=/Developer/ccache

