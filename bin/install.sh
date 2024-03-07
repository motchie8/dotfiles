#!/bin/bash
set -eu

cat /dev/null <<EOF
------------------------------------------------------------------------
Utility functions.
------------------------------------------------------------------------
EOF

DOTFILES_DIR=$(dirname $(dirname $(realpath $0)))

info_echo() {
    echo -e "\033[32m$1\033[0m"
}

err_echo() {
    echo -e "\033[31m$1\033[0m"
}

ARCH=$(uname -m)

cat /dev/null <<EOF
------------------------------------------------------------------------
Parse arguments.
------------------------------------------------------------------------
EOF

TMUX_PREFIX_KEY=""
BUILD_NEOVIM=false
SETUP_SYMBOLIC_LINKS=false

show_help() {
    echo "Usage: ./bin/install.sh -b -s -t TMUX_PREFIX_KEY"
    echo "  -h                    Show this help message and exit"
    echo "  -b                    Build Neovim from source"
    echo "  -s                    Setup symbolic links"
    echo "  -t TMUX_PREFIX_KEY    Specify prefix Key for tmux. ex. \"-t b\""
}

while getopts ":t:hbs" option; do
    case "${option}" in
        t) TMUX_PREFIX_KEY="${OPTARG}" ;;
        b) BUILD_NEOVIM=true ;;
        s) SETUP_SYMBOLIC_LINKS=true ;;
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
    sudo update-locale LANG=ja_JP.UTF-8
    # install dev dependencies
    sudo apt install -y curl git file zlib1g-dev libssl-dev \
        libreadline-dev libbz2-dev libsqlite3-dev wget cmake \
        pkg-config unzip libtool libtool-bin m4 automake gettext \
        zsh x11-apps libffi-dev yarn liblzma-dev gpg
    # install taskwarrior
    sudo apt-get install taskwarrior -y
    # install ripgrep for telescope
    sudo apt-get install ripgrep -y
    # install xdg-utils for opening browser
    sudo apt-get install xdg-utils -y
}

install_dev_libs_for_mac() {
    info_echo "**** Install dev libs for macOS ****"
    brew update
    set +e
    # install pyenv, vim plugins and zsh
    brew install node yarn wget tmux zsh source-highlight gcc cmake ripgrep
    # install taskwarrior
    brew install task ctags
    set -e
}

install_dev_libs() {
    if [ "$OS" = $UBUNTU ]; then
        install_dev_libs_for_ubuntu
    elif [ "$OS" = $MAC_OS ]; then
        install_dev_libs_for_mac
    else
        exit_with_unsupported_os
    fi
}

build_neovim() {
    info_echo "**** Build Neovim from source****"
    # install prerequisites
    if [ "$OS" = $UBUNTU ]; then
        sudo apt-get install -y ninja-build gettext cmake unzip curl
    elif [ "$OS" = $MAC_OS ]; then
        set +e
        brew install ninja cmake gettext curl
        set -e
    else
        exit_with_unsupported_os
    fi
    # build Neovim
    if [ ! -e $DOTFILES_DIR/neovim ]; then
        git clone https://github.com/neovim/neovim $DOTFILES_DIR/neovim
    fi
    cd $DOTFILES_DIR/neovim
    git pull origin master
    rm -rf build/
    make CMAKE_BUILD_TYPE=RelWithDebInfo
    sudo make install
}

install_neovim() {
    # cf. https://github.com/neovim/neovim/wiki/Installing-Neovim
    info_echo "**** Install or update Neovim ****"
    if [ "$OS" = $UBUNTU ]; then
        if [ "$BUILD_NEOVIM" = true ] || [ "$ARCH" == "arm64" ] || [ "$ARCH" == "aarch64" ]; then
            build_neovim
        else
            sudo apt-get install -y software-properties-common
            sudo add-apt-repository -y ppa:neovim-ppa/unstable
            sudo apt-get update -y
            sudo apt-get install -y neovim
        fi
    elif [ "$OS" = $MAC_OS ]; then
        if [ "$BUILD_NEOVIM" = true ]; then
            build_neovim
        else
            set +e
            brew unlink luajit
            brew unlink neovim
            brew install --HEAD luajit
            brew install --HEAD neovim
            brew link luajit
            brew link neovim
            set -e
        fi
    else
        exit_with_unsupported_os
    fi
}

install_anyenv_and_env_libs() {
    info_echo "**** Setup env libs ****"
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
        if ! pyenv versions | grep -q $NEOVIM_VIRTUAL_ENV; then
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
        if ! cat /etc/shells | grep -q "zsh"; then
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
    info_echo "**** Create or update .tmux.user.conf to set prefix key****"
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
        if ! git pull | grep -q "Already up to date"; then
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
            go_version="1.21.1"

            if [ "$ARCH" == "arm64" ] || [ "$ARCH" == "aarch64" ]; then
                wget -O go.tar.gz https://go.dev/dl/go${go_version}.linux-arm64.tar.gz
            elif [ "$ARCH" == "x86_64" ]; then
                wget -O go.tar.gz https://go.dev/dl/go${go_version}.linux-amd64.tar.gz
            else
                echo "Unsupported architecture: $ARCH"
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
    if ! type act >/dev/null 2>&1; then
        info_echo "**** Install act ***"
        if [ "$OS" = $UBUNTU ]; then
            if [ "$ARCH" == "arm64" ] || [ "$ARCH" == "aarch64" ]; then
                wget -O act.tar.gz https://github.com/nektos/act/releases/latest/download/act_Linux_arm64.tar.gz
            elif [ "$ARCH" == "x86_64" ]; then
                wget -O act.tar.gz https://github.com/nektos/act/releases/latest/download/act_Linux_x86_64.tar.gz
            else
                echo "Unsupported architecture: $ARCH"
                exit 1
            fi
            sudo tar xf act.tar.gz -C /usr/local/bin act
        elif [ "$OS" = $MAC_OS ]; then
            brew install act
        else
            exit_with_unsupported_os
        fi
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
            export GO111MODULE=on
            go install mvdan.cc/sh/v3/cmd/shfmt@latest
        elif [ "$OS" = $MAC_OS ]; then
            brew install shfmt
        else
            exit_with_unsupported_os
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
        if ! git pull | grep -q "Already up to date"; then
            info_echo "**** Update fzf ***"
            $DOTFILES_DIR/.fzf/install --key-bindings --completion --no-update-rc
        fi
        popd
    fi
}

install_terraform_libs() {
    if ! type terraform-docs >/dev/null 2>&1; then
        info_echo "**** Install terraform-docs ***"
        if [ "$OS" = $UBUNTU ]; then
            TERRAFORM_DOCS_VERSION="v0.17.0"
            go install github.com/terraform-docs/terraform-docs@${TERRAFORM_DOCS_VERSION}
            export PATH=$PATH:$HOME/go/bin
        elif [ "$OS" = $MAC_OS ]; then
            brew install terraform-docs
        else
            exit_with_unsupported_os
        fi
        # Setup code completion for zsh
        ZSH_COMPLETION_DIR="/usr/local/share/zsh/site-functions"
        TERRAFORM_DOCS_CODE_COMPLETION_PATH="${ZSH_COMPLETION_DIR}/_terraform-docs"
        if [ ! -e $TERRAFORM_DOCS_CODE_COMPLETION_PATH ]; then
            sudo mkdir -p $ZSH_COMPLETION_DIR
            terraform-docs completion zsh | sudo tee $TERRAFORM_DOCS_CODE_COMPLETION_PATH >/dev/null
        fi
    fi
    if ! type terraform-ls >/dev/null 2>&1; then
        info_echo "**** Install terraform-ls ***"
        if [ "$OS" = $UBUNTU ]; then
            wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
            sudo apt-get install -y lsb-release
            echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
            sudo apt update
            sudo apt install terraform-ls
        elif [ "$OS" = $MAC_OS ]; then
            brew install hashicorp/tap/terraform-ls
        else
            exit_with_unsupported_os
        fi
    fi
}

setup_dir() {
    if [ ! -e $HOME/vimwiki/todo ]; then
        info_echo "**** Create directory for vimwiki for task management****"
        mkdir -p $HOME/vimwiki/todo
    fi
    if [ ! -e $HOME/vimwiki/aichat ]; then
        info_echo "**** Create directory for vim-ai****"
        mkdir -p $HOME/vimwiki/aichat
    fi
}

install_nerd_fonts() {
    info_echo "**** Install nerd fonts ****"
    if [ $OS = $MAC_OS ]; then
        brew tap homebrew/cask-fonts
        brew install --cask font-roboto-mono-nerd-font
    fi
    # NOTE: install RobotMono Nerd Font for WSL manually
    # cf. Option 1: Download already patched font
    # https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts/RobotoMono
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
            exit_with_unsupported_os
        fi
    fi
}

install_aws_cli() {
    if ! type aws >/dev/null 2>&1; then
        info_echo "**** Install aws cli ****"
        if [ $OS = $MAC_OS ]; then
            brew install awscli
        elif [ "$OS" = $UBUNTU ]; then
            curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
            unzip awscliv2.zip
            sudo ./aws/install
            rm awscliv2.zip
            rm -rf aws
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
            sudo apt-get update -y
            sudo apt-get install -y helm
        else
            exit_with_unsupported_os
        fi
    fi
}

install_snowsql() {
    if ! type snowsql >/dev/null 2>&1; then
        info_echo "**** Install SnowSQL ****"
        if [ $OS = $MAC_OS ]; then
            if [ "$ARCH" == "x86_64" ]; then
                brew install --cask snowflake-snowsql
            else
                info_echo "Currently, for MacOS with arm64, SnowSQL needs to be installed using pkg."
                info_echo "cf. https://developers.snowflake.com/snowsql/"
            fi
        elif [ "$OS" = $UBUNTU ]; then
            if [ "$ARCH" == "x86_64" ]; then
                VERSION=1.2.28
                BOOTSTRAP_VERSION=1.2
                curl -O https://sfc-repo.snowflakecomputing.com/snowsql/bootstrap/${BOOTSTRAP_VERSION}/linux_x86_64/snowsql-${VERSION}-linux_x86_64.bash
                touch $DOTFILES_DIR/.zshrc.local
                SNOWSQL_DEST=$HOME/bin SNOWSQL_LOGIN_SHELL=$DOTFILES_DIR/.zshrc.local bash snowsql-${VERSION}-linux_x86_64.bash
            else
                info_echo "Currently, SnowSQL is not supported on arm64 Linux."
            fi
        else
            exit_with_unsupported_os
        fi
    fi
}

setup_symbolic_links() {
    if [ "$SETUP_SYMBOLIC_LINKS" = true ]; then
        source $DOTFILES_DIR/bin/setup_symbolic_links.sh
    fi
}

cat /dev/null <<EOF
------------------------------------------------------------------------
Installation steps
------------------------------------------------------------------------
EOF

install_dev_libs

install_neovim

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

install_aws_cli

install_heml

install_terraform_libs

install_snowsql

setup_symbolic_links

setup_dir

info_echo "**** Installation succeeded ****"
