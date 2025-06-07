#!/usr/bin/env bash
set -eu

cat /dev/null <<EOF
------------------------------------------------------------------------
Source common functions and variables.
------------------------------------------------------------------------
EOF
# source "$(dirname "$(realpath "$0")")/common.sh"
source "bin/common.sh"

cat /dev/null <<EOF
------------------------------------------------------------------------
Parse arguments.
------------------------------------------------------------------------
EOF

BUILD_FROM_SOURCE=false

show_help() {
    echo "Usage: ./bin/install_essentials.sh [-b]"
    echo "  -b                    Build cmake from source"
    echo "  -h                    Show this help message and exit"
}

while getopts "::hb" option; do
    case "${option}" in
        b) BUILD_FROM_SOURCE=true ;;
        h)
            show_help
            exit 0
            ;;
        *)
            show_help
            exit 1
            ;;
    esac
done

cat /dev/null <<EOF
------------------------------------------------------------------------
Main functions.
------------------------------------------------------------------------
EOF

install_dev_libs_for_ubuntu() {
    info_echo "**** Install dev libs for Ubuntu ****"
    if [ "$(whoami)" = "root" ]; then
        apt update -y && apt install -y sudo
    fi
    # set timezone
    TZ=Asia/Tokyo
    sudo ln -snf /usr/share/zoneinfo/"$TZ" /etc/localtime # && echo $TZ > /etc/timezone
    export DEBIAN_FEND=noninteractive
    sudo apt update -y && sudo apt install -y build-essential
    sudo apt-key adv --refresh-keys --keyserver keyserver.ubuntu.com
    sudo apt-get install -y language-pack-ja
    sudo update-locale LANG=ja_JP.UTF-8
    # install dev dependencies
    sudo apt install -y curl git file zlib1g-dev libssl-dev \
        libreadline-dev libbz2-dev libsqlite3-dev wget \
        pkg-config unzip libtool libtool-bin m4 automake gettext \
        zsh x11-apps libffi-dev yarn liblzma-dev gpg
    # install ripgrep for telescope
    sudo apt-get install ripgrep -y
    # install xdg-utils for opening browser
    sudo apt-get install xdg-utils -y
}

install_dev_libs_for_mac() {
    info_echo "**** Install dev libs for macOS ****"
    brew update
    set +e
    # install vim plugins and zsh
    brew install node yarn wget tmux zsh source-highlight gcc ripgrep
    set -e
}

install_dev_libs() {
    if [ "$OS" = "$UBUNTU" ]; then
        install_dev_libs_for_ubuntu
    elif [ "$OS" = "$MAC_OS" ]; then
        install_dev_libs_for_mac
    else
        exit_with_unsupported_os
    fi
}

install_cmake() {
    if ! type cmake >/dev/null 2>&1; then
        info_echo "**** Install cmake ****"
        if [ "$BUILD_FROM_SOURCE" = true ]; then
            info_echo "**** Build cmake from source ****"
            CMAKE_VERSION=3.29.3
            mkdir -p "$BUILD_DIR"/cmake
            cd "$BUILD_DIR"/cmake
            wget https://github.com/Kitware/CMake/archive/refs/tags/v"${CMAKE_VERSION}".tar.gz
            tar zxvf v"${CMAKE_VERSION}".tar.gz
            cd CMake-"${CMAKE_VERSION}"
            ./bootstrap
            make
            sudo make install
            cd "$DOTFILES_DIR"
        elif [ "$OS" = "$MAC_OS" ]; then
            info_echo "**** Install cmake by brew ****"
            brew install cmake
        elif [ "$OS" = "$UBUNTU" ]; then
            info_echo "**** Install cmake by apt ****"
            sudo apt install cmake -y
        else
            exit_with_unsupported_os
        fi
    else
        info_echo "**** cmake is already installed ****"
    fi
}

mkdir -p "$HOME/bin"
export PATH="$HOME/bin:$PATH"

install_dev_libs

install_cmake
