

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

# pyenv config
if which pyenv > /dev/null; then
    export PYENV_ROOT="${XDG_DATA_HOME}/pyenv"
    eval "$(pyenv init -)"
fi

export __ZDOTLOADED="$__ZDOTLOADED\n$ZDOTDIR/.zprofile"
