#!/bin/bash
set -eu

cat /dev/null <<EOF
------------------------------------------------------------------------
Utility functions.
------------------------------------------------------------------------
EOF

info_echo() {
    echo -e "\033[32m$1\033[0m"
}

err_echo() {
    echo -e "\033[31m$1\033[0m"
}


cat /dev/null <<EOF
------------------------------------------------------------------------
Validate operation system.
------------------------------------------------------------------------
EOF

# supported OS
MAC_OS="macOS"
UBUNTU="ubuntu"

if type sw_vers >/dev/null 2>&1; then
    OS=$MAC_OS
else
    OS=$(cat /etc/os-release | grep -E '^ID="?[^"]*"?$' | tr -d '"' | awk -F '[=]' '{print $NF}')
fi

exit_with_unsupported_os() {
    err_echo "Operation System '$OS' is not supported"
    exit 1
}

if [ "$OS" != $UBUNTU ] && [ "$OS" != $MAC_OS ]; then
    exit_with_unsupported_os
fi

cat /dev/null <<EOF
------------------------------------------------------------------------
Common variables.
------------------------------------------------------------------------
EOF

DOTFILES_DIR=$(dirname $(dirname $(realpath $0)))
BUILD_DIR=$DOTFILES_DIR/build
ARCH=$(uname -m)
