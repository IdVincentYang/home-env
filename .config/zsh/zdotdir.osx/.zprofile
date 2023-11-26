

# Homebrew installed bin path
if which /opt/homebrew/bin/brew > /dev/null; then
    eval $(/opt/homebrew/bin/brew shellenv)
fi

export PATH="$HOME/.local/bin:$PATH"

# android sdk path
if [ -d ~/Library/Android/sdk ]; then
    export ANDROID_SDK_ROOT=~/Library/Android/sdk
    export ANDROID_HOME=${ANDROID_SDK_ROOT}
    export PATH=${ANDROID_SDK_ROOT}/platform-tools:${PATH}
fi

# Java VM bin path
if which jenv > /dev/null; then
    export PATH="$HOME/.jenv/bin:$PATH"
    eval "$(jenv init -)"
fi

# This loads nvm
if [ -s "/opt/homebrew/opt/nvm/nvm.sh" ];  then
    export NVM_DIR="$HOME/.nvm"
    if [ ! -e "$NVM_DIR" ]; then
        mkdir "$NVM_DIR"
    fi
    source "/opt/homebrew/opt/nvm/nvm.sh"
fi

# pnpm
export PNPM_HOME="~/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# pyenv config
if which pyenv > /dev/null; then
    export PYENV_ROOT="${XDG_DATA_HOME}/pyenv"
    eval "$(pyenv init -)"

    if which which pyenv-virtualenv > /dev/null; then
        eval "$(pyenv virtualenv-init -)"
    fi
fi

export __ZDOTLOADED="$__ZDOTLOADED\n$ZDOTDIR/.zprofile"
