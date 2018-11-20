#!/usr/bin/env bash

_TEMP_PATH=$(dirname $0)
SCRIPT_DIR=${_TEMP_PATH/\.\./$(dirname $(pwd))}
SCRIPT_DIR=${SCRIPT_DIR/\.\//$(pwd)\/}
PARENT_DIR=$(dirname ${SCRIPT_DIR})

#########################################################################
##  Finder
#
#   显示隐藏文件
defaults write com.apple.finder AppleShowAllFiles -bool true


KillAll Finder
