#!/bin/bash
set -eu

cat /dev/null <<EOF
------------------------------------------------------------------------
Parse arguments.
------------------------------------------------------------------------
EOF

TMUX_PREFIX_KEY=""

show_help() {
    echo "Usage: ./bin/install.sh -t TMUX_PREFIX_KEY"
    echo "  -h                    Show this help message and exit"
    echo "  -t TMUX_PREFIX_KEY    Specify prefix Key for tmux. ex. \"-t b\""
}

while getopts ":t:h" option; do
    case "${option}" in
        t) TMUX_PREFIX_KEY="${OPTARG}" ;;
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

if [[ -z "${TMUX_PREFIX_KEY}" ]]; then
    show_help
    exit 1
fi

cat /dev/null <<EOF
------------------------------------------------------------------------
Validate operation system.
------------------------------------------------------------------------
EOF

MAC_OS="macOS"
UBUNTU="ubuntu"

if type sw_vers >/dev/null 2>&1; then
    OS=$MAC_OS
else
    OS=$(cat /etc/os-release | grep -E '^ID="?[^"]*"?$' | tr -d '"' | awk -F '[=]' '{print $NF}')
    if [ "$OS" != $UBUNTU ]; then
        echo "[ERROR] Operation System '$OS' is not supported"
        exit 1
    fi
fi

cat /dev/null <<EOF
------------------------------------------------------------------------
Utility functions.
------------------------------------------------------------------------
EOF

DOTFILES_DIR=$(pwd)

info_echo() {
    echo -e "\033[32m$1\033[0m"
}

err_echo() {
    echo -e "\033[31m$1\033[0m"
}

cat /dev/null <<EOF
------------------------------------------------------------------------
Functions for installation.
------------------------------------------------------------------------
EOF

install_dev_libs_for_ubuntu() {
    info_echo "**** Install dev libs for Ubuntu ****"
    if [ $(whoami) = "root" ]; then
        apt update -y && apt install -y sudo
    fi
    # set timezone
    TZ=Asia/Tokyo
    sudo ln -snf /usr/share/zoneinfo/$TZ /etc/localtime # && echo $TZ > /etc/timezone
    export DEBIAN_FEND=noninteractive
    sudo apt update -y && sudo apt install -y build-essential
    sudo apt-key adv --refresh-keys --keyserver keyserver.ubuntu.com
    sudo apt-get install -y language-pack-ja
    sudo apt-get install -y software-properties-common && sudo apt-get update -y
    sudo update-locale LANG=ja_JP.UTF-8
    # install dev dependencies
    sudo apt install -y curl git file zlib1g-dev libssl-dev \
        libreadline-dev libbz2-dev libsqlite3-dev wget cmake \
        pkg-config unzip libtool libtool-bin m4 automake gettext \
        zsh x11-apps libffi-dev yarn liblzma-dev
    # install taskwarrior
    sudo apt-get install taskwarrior -y
    # install ripgrep for telescope
    sudo apt-get install ripgrep -y
    # install xdg-utils for opening browser
    sudo apt-get install xdg-utils -y
    # install neovim nightly
    # NOTE: nvim-treesitter needs Neovim nightly
    sudo add-apt-repository -y ppa:neovim-ppa/unstable # ppa:neovim-ppa/stable
    sudo apt-get update -y && sudo apt-get install -y neovim
}

install_dev_libs_for_mac() {
    info_echo "**** Install dev libs for macOS ****"
    brew update
    set +e
    # install pyenv, vim plugins and zsh
    brew install node yarn wget tmux zsh source-highlight gcc cmake ripgrep # pyenv pyenv-virtualenv
    # install taskwarrior
    brew install task ctags
    # install neovim nightly
    brew unlink luajit
    brew unlink neovim
    brew install --HEAD luajit
    brew install --HEAD neovim
    brew link luajit
    brew link neovim
    set -e
}

install_dev_libs() {
    if [ "$OS" = $UBUNTU ]; then
        install_dev_libs_for_ubuntu
    elif [ "$OS" = $MAC_OS ]; then
        install_dev_libs_for_mac
    else
        err_echo "${OS} is not supported. Please use Ubuntu or macOS."
        exit 1
    fi
}

install_anyenv_and_env_libs() {
    info_echo "**** Setup *envs ****"
    if ! type anyenv >/dev/null 2>&1; then
        info_echo "**** Install anyenv ****"
        git clone https://github.com/anyenv/anyenv $HOME/.anyenv
        export PATH="$HOME/.anyenv/bin:$PATH"
        eval "$(anyenv init -)"
        anyenv install --force-init
    fi
    if ! type tfenv >/dev/null 2>&1; then
        info_echo "**** Install tfenv ****"
        anyenv install tfenv
        eval "$(anyenv init -)"
        tfenv install latest
    fi
    if ! type pyenv >/dev/null 2>&1; then
        info_echo "**** Install pyenv ****"
        anyenv install pyenv
        eval "$(anyenv init -)"
    fi
    if [ ! -e $(pyenv root)/plugins/pyenv-virtualenv ]; then
        info_echo "**** Install pyenv virtualenv****"
        git clone https://github.com/pyenv/pyenv-virtualenv.git $(pyenv root)/plugins/pyenv-virtualenv
        eval "$(pyenv virtualenv-init -)"
    fi
}

install_python() {
    # create envs and install python versions for neovim by pyenv-virtualenv
    PYTHON2_VERSION=2.7.18
    PYTHON3_VERSION=3.10.11
    PYTHON_VERSIONS=($PYTHON2_VERSION $PYTHON3_VERSION)
    NEOVIM_VIRTUAL_ENVS=("neovim2" "neovim3")
    i=0
    for PYTHON_VERSION in "${PYTHON_VERSIONS[@]}"; do
        NEOVIM_VIRTUAL_ENV=${NEOVIM_VIRTUAL_ENVS[i]}
        result=0
        output=$(pyenv versions | grep -q $NEOVIM_VIRTUAL_ENV) || result=$?
        if [ $result -ne 0 ]; then
            info_echo "**** Install python ${PYTHON_VERSION} ****"
            pyenv install -s $PYTHON_VERSION
            info_echo "**** Setup python virtualenv ${NEOVIM_VIRTUAL_ENV} ****"
            pyenv virtualenv $PYTHON_VERSION $NEOVIM_VIRTUAL_ENV
            PYTHON_PATH=$(pyenv root)/versions/$NEOVIM_VIRTUAL_ENV/bin/python
            eval "$PYTHON_PATH -m pip install --upgrade pip"
            eval "$PYTHON_PATH -m pip install pynvim neovim"
            if [ "$NEOVIM_VIRTUAL_ENV" = "neovim3" ]; then
                eval "$PYTHON_PATH -m pip install -r $DOTFILES_DIR/python/requirements.txt"
                pyenv global $NEOVIM_VIRTUAL_ENV
            fi
        fi
        i=$(expr $i + 1)
    done
}

install_zsh_and_set_as_default_shell() {
    DEFAULT_SHELL=$(echo $SHELL | awk -F '[/]' '{print $NF}')
    if [ "$DEFAULT_SHELL" != "zsh" ]; then
        info_echo "**** Change default shell from ${DEFAULT_SHELL} to zsh ****"
        result=$(cat /etc/shells | grep -q "zsh")
        if [ $? -ne 0 ]; then
            echo $(which zsh) >>/etc/shells
        fi
        sudo chsh -s $(which zsh) $(whoami)
    fi
}

setup_zsh() {
    # install zplug
    export ZPLUG_HOME=$DOTFILES_DIR/.zplug
    if [ ! -e $ZPLUG_HOME ]; then
        info_echo "**** Install zplug ****"
        git clone https://github.com/zplug/zplug $ZPLUG_HOME
    else
        info_echo "**** Update zplug ****"
        pushd $ZPLUG_HOME
        git pull
        popd
    fi
    # install zprezto and setup zsh dotfiles
    if [ ! -e $DOTFILES_DIR/.zprezto ]; then
        info_echo "**** Install zprezto ****"
        git clone --recursive https://github.com/sorin-ionescu/prezto.git $DOTFILES_DIR/.zprezto
        for rcfile_name in zlogin zlogout zpreztorc zprofile zshenv; do
            if [ ! -e $HOME/$rcfile_name ]; then
                ln -s "$DOTFILES_DIR/.zprezto/runcoms/.$rcfile_name" "$HOME/.$rcfile_name"
            fi
        done
    else
        info_echo "**** Update zprezto ****"
        pushd $DOTFILES_DIR/.zprezto
        git pull
        popd
    fi
}

install_iceberg_tmux_conf() {
    # download iceberg.tmux.conf
    if [ ! -e $DOTFILES_DIR/tmux/colors/iceberg.tmux.conf ]; then
        info_echo "**** Install tmux color schema ****"
        mkdir -p $DOTFILES_DIR/tmux/colors/
        wget -O $DOTFILES_DIR/tmux/colors/iceberg.tmux.conf https://raw.githubusercontent.com/gkeep/iceberg-dark/master/.tmux/iceberg.tmux.conf
    fi
}

install_node() {
    # install or update npm and node for coc-nvim
    if ! type nvm >/dev/null 2>&1; then
        info_echo "**** Install nvm ****"
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
    fi
    if ! type node >/dev/null 2>&1; then
        info_echo "**** Install node ****"
        nvm install 16.15.1
        # nvm use --lts
    fi
}

install_packer_nvim() {
    # install nvim package manager
    if [ ! -e $HOME/.local/share/nvim/site/pack/packer/start ]; then
        info_echo "**** Install packer.nvim ****"
        mkdir -p $DOTFILES_DIR/.vim/plugins
        git clone --depth 1 https://github.com/wbthomason/packer.nvim $HOME/.local/share/nvim/site/pack/packer/start/packer.nvim
    else
        info_echo "**** Update packer.nvim ****"
        pushd $HOME/.local/share/nvim/site/pack/packer/start/packer.nvim
        git pull
        popd
    fi
}

create_tmux_user_conf() {
    # create .tmux.user.conf for custom prefix key
    cat <<EOL >$DOTFILES_DIR/tmux/tmux.user.conf
unbind C-b
set-option -g prefix C-${TMUX_PREFIX_KEY}
bind-key C-${TMUX_PREFIX_KEY} send-prefix
EOL
}

install_tmux_mem_cpu_load() {
    # install tmux-mem-cpu-load
    if [ ! -e $DOTFILES_DIR/tmux/plugins/tmux-mem-cpu-load ]; then
        info_echo "**** Install tmux-mem-cpu-load ****"
        mkdir -p $DOTFILES_DIR/tmux/plugins
        git clone https://github.com/thewtex/tmux-mem-cpu-load.git $DOTFILES_DIR/tmux/plugins/tmux-mem-cpu-load
        pushd $DOTFILES_DIR/tmux/plugins/tmux-mem-cpu-load
        cmake .
        make
        sudo make install
        popd
    else
        pushd $DOTFILES_DIR/tmux/plugins/tmux-mem-cpu-load
        result=0
        output=$(git pull | grep -q "Already up to date") || result=$?
        if [ $result -ne 0 ]; then
            info_echo "**** Update tmux-mem-cpu-load ****"
            cmake .
            make
            sudo make install
        fi
        popd
    fi
}

install_go() {
    if ! type go >/dev/null 2>&1; then
        info_echo "**** Install go****"
        if type brew >/dev/null 2>&1; then
            brew install go
        else
            arch=$(uname -m)
            go_version="1.12.1"

            if [ "$arch" == "arm64" ]; then
                wget -O go.tar.gz https://go.dev/dl/go${go_version}.linux-arm64.tar.gz
            elif [ "$arch" == "x86_64" ]; then
                wget -O go.tar.gz https://go.dev/dl/go${go_version}.linux-amd64.tar.gz
            else
                echo "Unsupported architecture: $arch"
                exit 1
            fi
            sudo rm -rf /usr/local/go
            sudo tar -C /usr/local -xzf go.tar.gz
            rm go.tar.gz
        fi
        # setup PATH to use go lang to install modules in the following steps
        export PATH=$PATH:/usr/local/go/bin
    fi
}

install_act() {
    if [ ! -e ~/go/bin/act ]; then
        info_echo "**** Install act ****"
        curl https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash
    fi
}

install_rust() {
    if ! type cargo >/dev/null 2>&1; then
        info_echo "**** Install rust ****"
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs >install_rust.sh
        sh install_rust.sh -y
        rm install_rust.sh
        export PATH="$HOME/bin:$HOME/.cargo/bin:$PATH"
    fi
}

install_formatter() {
    # install sh formatter
    if ! type shfmt >/dev/null 2>&1; then
        info_echo "**** Install shfmt for sh formatter ****"
        if [ "$OS" = $UBUNTU ]; then
            go install mvdan.cc/sh/v3/cmd/shfmt@latest
        elif [ "$OS" = $MAC_OS ]; then
            brew install shfmt
        else
            echo "[ERROR] Operation System '$OS' is not supported"
            exit 1
        fi
    fi

    # install rust formatter
    if ! type stylua >/dev/null 2>&1; then
        info_echo "**** Install stylua for rust formatter ***"
        cargo install stylua
    fi
    # install toml formatter
    #if ! type taplo >/dev/null 2>&1; then
    #    export OPENSSL_DIR=/usr/include/openssl
    #    cargo install taplo-cli
    #fi

    # install formatter for various filetypes
    if ! type prettier >/dev/null 2>&1; then
        info_echo "**** Install prettier for formatter for various filetypes ***"
        npm -g install prettier
    fi
}

install_fzf() {
    if [ ! -e $DOTFILES_DIR/.fzf ]; then
        info_echo "**** Install fzf ***"
        git clone --depth 1 https://github.com/junegunn/fzf.git $DOTFILES_DIR/.fzf
        $DOTFILES_DIR/.fzf/install --key-bindings --completion --no-update-rc
    else
        pushd $DOTFILES_DIR/.fzf
        result=0
        output=$(git pull | grep -q "Already up to date") || result=$?
        if [ $result -ne 0 ]; then
            info_echo "**** Update fzf ***"
            $DOTFILES_DIR/.fzf/install --key-bindings --completion --no-update-rc
        fi
        popd
    fi
}

install_terraform_docs() {
    if ! type terraform-docs >/dev/null 2>&1; then
        info_echo "**** Install terraform-docs ***"
        if [ "$OS" = $UBUNTU ]; then
            TERRAFORM_DOCS_VERSION="v0.16.0"
            go install github.com/terraform-docs/terraform-docs@${TERRAFORM_DOCS_VERSION}
        elif [ "$OS" = $MAC_OS ]; then
            brew install terraform-docs
        else
            echo "[ERROR] Operation System '$OS' is not supported"
            exit 1
        fi
        # Setup code completion for zsh
        ZSH_COMPLETION_DIR="/usr/local/share/zsh/site-functions"
        TERRAFORM_DOCS_CODE_COMPLETION_PATH="${ZSH_COMPLETION_DIR}/_terraform-docs"
        if [ ! -e $TERRAFORM_DOCS_CODE_COMPLETION_PATH ]; then
            sudo mkdir -p $ZSH_COMPLETION_DIR
            terraform-docs completion zsh | sudo tee $TERRAFORM_DOCS_CODE_COMPLETION_PATH >/dev/null
        fi
    fi
}

setup_symbolic_links() {
    info_echo "**** Setup symbolic links ****"
    target_paths=("$HOME/.zshrc" "$HOME/.config/nvim" "$HOME/.config/nvim/coc-settings.json" "$HOME/.config/nvim/init.lua" "$HOME/.config/nvim/cheatsheet.txt" "$HOME/.tmux.conf")
    link_paths=("$DOTFILES_DIR/.zshrc" "$DOTFILES_DIR/.vim" "$DOTFILES_DIR/coc-settings.json" "$DOTFILES_DIR/init.lua" "$DOTFILES_DIR/cheatsheet.txt" "$DOTFILES_DIR/tmux/tmux.common.conf")
    mkdir -p ~/.config
    for i in "${!target_paths[@]}"; do
        if [ -e "${target_paths[i]}" ]; then
            if [ ! -L "${target_paths[i]}" ]; then
                info_echo "File already exists at ${target_paths[i]}, so skip creating symbolic link"
                continue
            else
                unlink "${target_paths[i]}"
            fi
        fi
        ln -s "${link_paths[i]}" "${target_paths[i]}"
    done
}

setup_dir() {
    info_echo "**** Setup directory for vimwiki ****"
    # make vimwiki directories
    mkdir -p ~/vimwiki/data/todo
}

install_nerd_fonts() {
    info_echo "**** Install nerd fonts ****"
    if [ $OS = $MAC_OS ]; then
        brew tap homebrew/cask-fonts
        brew install --cask font-roboto-mono-nerd-font
    fi
    # TODO: add installation step for ubuntu
}

install_gcloud_cli() {
    if ! type gcloud >/dev/null 2>&1; then
        info_echo "**** Install gcloud cli ****"
        if [ $OS = $MAC_OS ]; then
            brew install --cask google-cloud-sdk
        elif [ "$OS" = $UBUNTU ]; then
            sudo apt-get install -y apt-transport-https ca-certificates gnupg curl sudo
            echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
            curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
            sudo apt-get update && sudo apt-get install -y google-cloud-cli
            # NOTE: init gcloud CLI by running `gcloud init`
        else
            echo "[ERROR] Operation System '$OS' is not supported"
            exit 1
        fi
    fi
}

install_heml() {
    if ! type helm >/dev/null 2>&1; then
        info_echo "**** Install Helm ****"
        if [ $OS = $MAC_OS ]; then
            brew install helm
        elif [ "$OS" = $UBUNTU ]; then
            curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg >/dev/null
            sudo apt-get install apt-transport-https --yes
            echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
            sudo apt-get update
            sudo apt-get install helm
        else
            echo "[ERROR] Operation System '$OS' is not supported"
            exit 1
        fi
    fi
}

cat /dev/null <<EOF
------------------------------------------------------------------------
Installation steps
------------------------------------------------------------------------
EOF

install_dev_libs

install_anyenv_and_env_libs

install_python

install_zsh_and_set_as_default_shell

setup_zsh

install_iceberg_tmux_conf

install_node

install_packer_nvim

install_tmux_mem_cpu_load

install_go

install_act

install_rust

install_formatter

install_fzf

create_tmux_user_conf

install_nerd_fonts

install_gcloud_cli

install_heml

install_terraform_docs

setup_symbolic_links

setup_dir

info_echo "**** Installation succeeded ****"
