#!/usr/bin/env bash
set -eu

cat /dev/null <<EOF
------------------------------------------------------------------------
Source common functions and variables.
------------------------------------------------------------------------
EOF
source "bin/common.sh"

cat /dev/null <<EOF
------------------------------------------------------------------------
Parse arguments.
------------------------------------------------------------------------
EOF

show_help() {
    echo "Usage: ./bin/install_essentials.sh"
    echo "  -h                    Show this help message and exit"
}

while getopts "::h" option; do
    case "${option}" in
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
        uv tool install cmake
    fi
}

install_uv() {
    if ! type uv >/dev/null 2>&1; then
        info_echo "**** Install uv ****"
        export UV_NO_MODIFY_PATH=1
        curl -LsSf https://astral.sh/uv/install.sh | sh
    fi
}

install_python() {
    if ! type python3 >/dev/null 2>&1; then
        info_echo "**** Install python3 ****"
        uv python install 3.12 --default --preview
    fi
    if [ -e "$DOTFILES_DIR"/.venv ]; then
        info_echo """**** Setup virtual environment for dotfiles ****"""
        cd "$DOTFILES_DIR"
        uv sync
    fi
}

install_node() {
    # install or update npm and node for coc-nvim
    if ! type nvm >/dev/null 2>&1; then
        info_echo "**** Install nvm ****"
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
        export NVM_DIR="$HOME/.nvm"
        # shellcheck disable=SC1091
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
    fi
    if ! type node >/dev/null 2>&1; then
        info_echo "**** Install node ****"
        NODE_VERSION=22.16.0
        nvm install "$NODE_VERSION"
        nvm alias default "$NODE_VERSION"
        nvm use "$NODE_VERSION"
    fi
}

install_go() {
    if ! type go >/dev/null 2>&1; then
        info_echo "**** Install go****"
        if type brew >/dev/null 2>&1; then
            brew install go
        else
            go_version="1.24.4"
            if [ "$ARCH" == "arm64" ] || [ "$ARCH" == "aarch64" ]; then
                wget -O go.tar.gz https://go.dev/dl/go"${go_version}.linux-arm64.tar.gz"
            elif [ "$ARCH" == "x86_64" ]; then
                wget -O go.tar.gz https://go.dev/dl/go"${go_version}.linux-amd64.tar.gz"
            else
                echo "Unsupported architecture: $ARCH"
                exit 1
            fi
            sudo rm -rf /usr/local/go
            sudo tar -C /usr/local -xzf go.tar.gz
            rm go.tar.gz
        fi
    fi
}

install_rust() {
    if ! type cargo >/dev/null 2>&1; then
        info_echo "**** Install rust ****"
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs >rustup-init.sh
        sh rustup-init.sh -y --no-modify-path
        rm rustup-init.sh
    fi
}

if [ ! -e "$HOME/bin" ]; then
    mkdir -p "$HOME/bin"
fi

install_dev_libs

install_uv

install_python

install_cmake

install_node

install_go

install_rust
