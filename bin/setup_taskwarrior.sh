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
    echo "Usage: ./bin/setup_taskwarrior.sh [-b]"
    echo "  -b                    Build taskwarrior from source"
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

install_taskwarrior_from_source() {
    if ! type rustup >/dev/null 2>&1; then
        err_echo "rust is not installed. Please install rust first using bin/install-dev-env-libs.sh"
        exit 1
    fi
    # install prerequisites
    if [ "$OS" = "$UBUNTU" ]; then
        sudo apt-get update
        sudo apt-get install uuid-dev -y
    fi
    if [ ! -e "$BUILD_DIR"/task ]; then
        info_echo "**** Install TaskWarrior from source ****"
        git clone --branch develop https://github.com/GothenburgBitFactory/taskwarrior.git "$BUILD_DIR"/task
        mkdir -p "$BUILD_DIR"/task/build
        cd "$BUILD_DIR"/task/build
        cmake -DCMAKE_BUILD_TYPE=release ../
        make
        sudo make install
        cd "$DOTFILES_DIR"
    else
        cd "$BUILD_DIR"/task
        if ! git pull | grep -q "Already up to date"; then
            info_echo "**** Update TaskWarrior ****"
            rm -rf build
            mkdir -p build
            cd build
            cmake -DCMAKE_BUILD_TYPE=release ../
            make
            sudo make install
        else
            info_echo "**** TaskWarrior is already up to date ****"
        fi
    fi
}

install_taskwarrior_from_package() {
    if [ "$OS" = "$UBUNTU" ]; then
        sudo apt-get update
        sudo apt-get install taskwarrior -y
    elif [ "$OS" = "$MAC_OS" ]; then
        brew install task
    else
        exit_with_unsupported_os
    fi
}

install_taskwarrior() {
    if ! type task >/dev/null 2>&1; then
        info_echo "**** Install TaskWarrior ****"
        if [ "$BUILD_FROM_SOURCE" = true ]; then
            install_taskwarrior_from_source
        else
            install_taskwarrior_from_package
        fi
    else
        info_echo "**** TaskWarrior is already installed ****"
    fi
}

install_taskwarrior
