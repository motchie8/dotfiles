#!/usr/bin/env bash
set -eu

cat /dev/null <<EOF
------------------------------------------------------------------------
Utility functions.
------------------------------------------------------------------------
EOF

info_echo() {
    echo -e "\033[32m$(date '+%Y-%m-%d %H:%M:%S') [INFO] $1\033[0m"
}

err_echo() {
    echo -e "\033[31m$(date '+%Y-%m-%d %H:%M:%S') [ERROR] $1\033[0m"
}

if [ "${DEBUG:-}" = "true" ]; then
    set -x
fi

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
    OS=$(grep -E '^ID="?[^"]*"?$' /etc/os-release | tr -d '"' | awk -F '[=]' '{print $NF}')
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

DOTFILES_DIR=$(dirname "$(dirname "$(realpath "$0")")")
BUILD_DIR=$DOTFILES_DIR/build
ARCH=$(uname -m)

export DOTFILES_DIR BUILD_DIR ARCH

cat /dev/null <<EOF
------------------------------------------------------------------------
Utility functions.
------------------------------------------------------------------------
EOF

setup_path() {
    if ! echo "$PATH" | grep -q "$HOME/bin:"; then
        export PATH="$HOME/bin:$PATH"
    fi
    if ! echo "$PATH" | grep -q "$HOME/.local/bin:"; then
        export PATH="$HOME/.local/bin:$PATH"
    fi
    if ! echo "$PATH" | grep -q "/usr/local/go/bin:"; then
        export PATH="$PATH:/usr/local/go/bin"
    fi
    if ! echo "$PATH" | grep -q "$HOME/go/bin:"; then
        export PATH="$PATH:$HOME/go/bin"
    fi
    if ! echo "$PATH" | grep -q "$HOME/.anyenv/bin:"; then
        export PATH="$PATH:$HOME/.anyenv/bin"
    fi
    if ! echo "$PATH" | grep -q "$HOME/.cargo/bin:"; then
        export PATH="$PATH:$HOME/.cargo/bin"
    fi
    if [ -z "${NVIM_DIR:-}" ]; then
        export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
        if [ -s "$NVM_DIR/nvm.sh" ]; then
            set +e
            # shellcheck source=/dev/null
            \. "$NVM_DIR/nvm.sh"
            set -e
        fi
    fi
}

setup_path
