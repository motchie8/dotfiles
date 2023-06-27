#!/usr/bin/env bash
set -eu

DOTFILES_DIR=$HOME/.dotfiles

usage_exit() {
    cat <<EOF
Usage: $0 --tmux-prefix-key b" 1>&2
    --tmux-prefix-key
        Character to use as tmux prefix key
EOF
    exit 1
}

parse_args() {
    OPT=$(getopt -o h -l tmux-prefix-key:,help -- "$@")
    if [ $? != 0 ]; then
        usage_exit
    fi
    eval set -- "$OPT"
    while true; do
        case $1 in
            --tmux-prefix-key)
                TMUX_PREFIX_KEY=$2
                shift 2
                ;;
            -h | --help)
                usage_exit
                ;;
            --)
                shift
                break
                ;;
            *)
                echo "Unexpected behavior" 1>&2
                exit 1
                ;;
        esac
    done
}

check_args() {
    if [ "${TMUX_PREFIX_KEY:-}" = "" ]; then
        usage_exit
    fi
}

create_tmux_user_conf() {
    # create .tmux.user.conf for custom prefix key
    cat <<EOL >$DOTFILES_DIR/.tmux/.tmux.user.conf
unbind C-b
set-option -g prefix C-${TMUX_PREFIX_KEY}
bind-key C-${TMUX_PREFIX_KEY} send-prefix
EOL
}

get_os() {
    OS=$(cat /etc/os-release | grep -E '^ID="?[^"]*"?$' | tr -d '"' | awk -F '[=]' '{print $NF}')
}

install_dev_libs_for_amzn() {
    if [ $(whoami) = "root" ]; then
        yum update -y && yum install -y sudo
    fi
    sudo yum update -y && sudo yum groupinstall "Development Tools" -y
    # install zsh, pyenv and vim plugin dependencies
    # uninstall openssl10 for openssl11
    sudo yum remove openssl -y
    sudo yum install -y git xsel zlib-devel bzip2 bzip2-devel \
        readline-devel sqlite sqlite-devel openssl11-devel xz \
        xz-devel libffi-devel make libtool autoconf automake \
        cmake gcc gcc-c++ make pkgconfig unzip xclip gettext \
        patch ctags zsh wget util-linux-user which
    # install taskwarrior
    sudo amazon-linux-extras install epel -y
    sudo yum install task -y
    # install xclip
    sudo amazon-linux-extras install epel -y
    sudo yum-config-manager --enable epel
    sudo yum install xclip -y
    # install ripgrep for telescope
    sudo yum-config-manager --add-repo=https://copr.fedorainfracloud.org/coprs/carlwgeorge/ripgrep/repo/epel-7/carlwgeorge-ripgrep-epel-7.repo
    sudo yum install ripgrep -y
    # install neovim prerequisites
    sudo yum -y install ninja-build libtool autoconf automake \
        gcc gcc-c++ make pkgconfig unzip patch gettext curl
    # install or update pyenv
    # if ! type pyenv >/dev/null 2>&1; then
    #     curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash
    #     # exec $SHELL -l
    #     export PATH="$HOME/.pyenv/bin:$PATH"
    #     export PYENV_PATH=$HOME/.pyenv
    #     export PROMPT_COMMAND=""
    #     export PYENV_VIRTUALENV_DISABLE_PROMPT=1
    #     export _OLD_VIRTUAL_PATH=""
    #     export _OLD_VIRTUAL_PYTHONHOME=""
    #     export _OLD_VIRTUAL_PS1=""
    #     eval "$(pyenv init --path)"
    #     eval "$(pyenv virtualenv-init -)"
    # else
    #     pyenv update
    # fi
    # install cmake v3 for nvim
    if [ ! -e $DOTFILES_DIR/cmake-3.26.4 ]; then
        # uninstall cmake v2
        sudo yum remove cmake -y
        pushd $DOTFILES_DIR
        wget https://cmake.org/files/v3.26/cmake-3.26.4.tar.gz
        tar -xvzf cmake-3.26.4.tar.gz
        pushd cmake-3.26.4
        ./bootstrap --prefix=/usr
        make
        sudo make install
        popd
        popd
    fi
    # install neovim
    if ! type nvim >/dev/null 2>&1; then
        echo "[INFO] install neovim for $OS"
        pushd $DOTFILES_DIR
        git clone https://github.com/neovim/neovim
        popd
        pushd $DOTFILES_DIR/neovim
        make clean
        make CMAKE_BUILD_TYPE=RelWithDebInfo
        sudo make install
        sudo ln -s -T /usr/local/bin/nvim /usr/bin/nvim
        popd
    fi
    # update neovim
    pushd $DOTFILES_DIR/neovim
    result=0
    output=$(git pull | grep -q "Already up to date") || result=$?
    if [ $result -ne 0 ]; then
        echo "[INFO] update neovim"
        sudo make distclean
        make CMAKE_BUILD_TYPE=RelWithDebInfo
        sudo make install
    fi
    popd
}

install_dev_libs_for_ubuntu() {
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
        zsh x11-apps libffi-dev yarn
    # install taskwarrior
    sudo apt-get install taskwarrior -y
    # install ripgrep for telescope
    sudo apt-get install ripgrep -y
    # install neovim nightly
    # NOTE: nvim-treesitter needs Neovim nightly
    sudo add-apt-repository -y ppa:neovim-ppa/unstable # ppa:neovim-ppa/stable
    sudo apt-get update -y && sudo apt-get install -y neovim 
}

install_anyenv_and_env_libs() {
    if [ ! -e $HOME/.anyenv ]; then
    	git clone https://github.com/anyenv/anyenv $HOME/.anyenv
	export PATH="$HOME/.anyenv/bin:$PATH"
	eval "$(anyenv init -)"
	anyenv install --force-init
	exec $SHELL -l
    fi
    if ! type tfenv >/dev/null 2>&1; then
        anyenv install tfenv
	exec $SHELL -l
    fi
    if ! type pyenv >/dev/null 2>&1; then
        anyenv install pyenv
	exec $SHELL -l
	git clone https://github.com/pyenv/pyenv-virtualenv.git $(pyenv root)/plugins/pyenv-virtualenv
	eval "$(pyenv virtualenv-init -)"
	exec "$SHELL"
    fi
}

install_dev_libs_for_mac() {
    brew update
    set +e
    # install pyenv, vim plugins and zsh
    brew install node yarn wget tmux go zsh source-highlight gcc cmake ripgrep  # pyenv pyenv-virtualenv
    # install taskwarrior
    brew install task ctags
    # install neovim nightly
    brew unlink luajit
    brew unlink neovim
    brew install --HEAD luajit
    brew install --HEAD neovim
    set -e
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
            pyenv install -s $PYTHON_VERSION
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
        result=$(cat /etc/shells | grep -q "zsh")
        echo "[INFO] Change default shell to zsh"
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
        echo "[INFO] Install zplug"
        git clone https://github.com/zplug/zplug $ZPLUG_HOME
    else
        pushd $ZPLUG_HOME
        git pull
        popd
    fi
    # install zprezto and setup zsh dotfiles
    if [ ! -e $DOTFILES_DIR/.zprezto ]; then
        echo "[INFO] Install zprezto"
        git clone --recursive https://github.com/sorin-ionescu/prezto.git $DOTFILES_DIR/.zprezto
        for rcfile_name in zlogin zlogout zpreztorc zprofile zshenv; do
            if [ ! -e $HOME/$rcfile_name ]; then
                ln -s "$DOTFILES_DIR/.zprezto/runcoms/.$rcfile_name" "$HOME/.$rcfile_name"
            fi
        done
    else
        pushd $DOTFILES_DIR/.zprezto
        git pull
        popd
    fi
}

install_iceberg_tmux_conf() {
    # download iceberg.tmux.conf
    if [ ! -e $DOTFILES_DIR/.tmux/colors/iceberg.tmux.conf ]; then
        mkdir -p $DOTFILES_DIR/.tmux/colors/
        wget -O $DOTFILES_DIR/.tmux/colors/iceberg.tmux.conf https://raw.githubusercontent.com/gkeep/iceberg-dark/master/.tmux/iceberg.tmux.conf
    fi
}

install_node() {
    # install or update npm and node for coc-nvim
    if ! type node >/dev/null 2>&1; then
        echo "[INFO] Install node"
        # curl -sL install-node.now.sh/lts | bash
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
        nvm install 16.15.1
        # nvm use --lts
    fi
}

install_packer_nvim() {
    # install nvim package manager
    if [ ! -e $HOME/.local/share/nvim/site/pack/packer/start ]; then
        echo "[INFO] Install packer.nvim"
        mkdir -p $DOTFILES_DIR/.vim/plugins
        git clone --depth 1 https://github.com/wbthomason/packer.nvim $HOME/.local/share/nvim/site/pack/packer/start/packer.nvim
    else
        pushd $HOME/.local/share/nvim/site/pack/packer/start/packer.nvim
        git pull
        popd
    fi
}

install_tmux_mem_cpu_load() {
    # install tmux-mem-cpu-load
    if [ ! -e $DOTFILES_DIR/.tmux/plugins/tmux-mem-cpu-load ]; then
        echo "[INFO] Install tmux-mem-cpu-load"
        mkdir -p $DOTFILES_DIR/.tmux/plugins
        git clone https://github.com/thewtex/tmux-mem-cpu-load.git $DOTFILES_DIR/.tmux/plugins/tmux-mem-cpu-load
        pushd $DOTFILES_DIR/.tmux/plugins/tmux-mem-cpu-load
        cmake .
        make
        if type sw_vers >/dev/null 2>&1; then
            make install
        else
            sudo make install
        fi
        popd
    else
        pushd $DOTFILES_DIR/.tmux/plugins/tmux-mem-cpu-load
        result=0
        output=$(git pull | grep -q "Already up to date") || result=$?
        if [ $result -ne 0 ]; then
            cmake .
            make
            if type sw_vers >/dev/null 2>&1; then
                make install
            else
                sudo make install
            fi
        fi
        popd
    fi
}

install_go() {
    # install go
    if ! type go >/dev/null 2>&1; then
        echo "[INFO] Install go lang"
        if type brew >/dev/null 2>&1; then
            brew install go
        else
            wget https://go.dev/dl/go1.17.6.linux-amd64.tar.gz
            sudo rm -rf /usr/local/go
            sudo tar -C /usr/local -xzf go1.17.6.linux-amd64.tar.gz
            rm go1.17.6.linux-amd64.tar.gz
            export PATH=$PATH:/usr/local/go/bin
        fi
    fi
}

install_act() {
    if [ ! -e ~/go/bin/act ]; then
        echo "[INFO] Install act"
        curl https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash
    fi
}

install_rust() {
    if ! type cargo >/dev/null 2>&1; then
        echo "[INFO] Install rust"
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs >install_rust.sh
        sh install_rust.sh -y
        rm install_rust.sh
        export PATH="$HOME/bin:$HOME/.cargo/bin:$PATH"
    fi
}

install_formatter() {
    # install sh formatter
    if ! type shfmt >/dev/null 2>&1; then
	echo "[INFO] Install shfmt"
	if [ "$OS" = "amzn" ]; then
	    sudo yum install shfmt -y
	elif [ "$OS" = "ubuntu" ]; then
	    sudo apt install shfmt
	elif type sw_vers >/dev/null 2>&1; then
	    brew install shfmt
	else
	    echo "[ERROR] '$OS' is not supported"
	    exit 1
	fi
    fi

    # install rust formatter
    if ! type stylua >/dev/null 2>&1; then
        echo "[INFO] Install stylua"
        cargo install stylua
    fi
    # install toml formatter
    #if ! type taplo >/dev/null 2>&1; then
    #    export OPENSSL_DIR=/usr/include/openssl
    #    cargo install taplo-cli
    #fi

    # install formatter for various filetypes
    if ! type prettier >/dev/null 2>&1; then
        npm -g install prettier
    fi
}

install_fzf() {
    # install fzf
    if [ ! -e $DOTFILES_DIR/.fzf ]; then
        git clone --depth 1 https://github.com/junegunn/fzf.git $DOTFILES_DIR/.fzf
        $DOTFILES_DIR/.fzf/install --key-bindings --completion --no-update-rc
    else
        pushd $DOTFILES_DIR/.fzf
        result=0
        output=$(git pull | grep -q "Already up to date") || result=$?
        if [ $result -ne 0 ]; then
            $DOTFILES_DIR/.fzf/install --key-bindings --completion --no-update-rc
        fi
        popd
    fi
}

install_deno() {
    if ! type deno >/dev/null 2>&1; then
        echo "[INFO] Install Deno"
        curl -fsSL https://deno.land/x/install/install.sh | sh
    fi
}

# NOTE: Commented out because it is not currently in use
## install lemonade to copy text from Linux to Windows via SSH
#if ! type lemonade > /dev/null 2>&1; then
#  go get github.com/pocke/lemonade
#  cd ~/go/src/github.com/lemonade-command/lemonade/
#  make install
#  sudo ln -s -T ~/go/bin/lemonade /usr/local/bin/lemonade
#fi

setup_symbolic_links() {
    target_paths=("$HOME/.zshrc" "$HOME/.config/nvim" "$HOME/.config/nvim/coc-settings.json" "$HOME/.config/nvim/init.lua" "$HOME/.config/nvim/cheatsheet.txt" "$HOME/.tmux.conf")
    link_paths=("$HOME/.dotfiles/.zshrc" "$HOME/.dotfiles/.vim" "$HOME/.dotfiles/coc-settings.json" "$HOME/.dotfiles/init.lua" "$HOME/.dotfiles/cheatsheet.txt" "$HOME/.dotfiles/.tmux/.tmux.common.conf")
    mkdir -p ~/.config
    for i in "${!target_paths[@]}"; do
        if [ -e "${target_paths[i]}" ]; then
            if [ ! -L "${target_paths[i]}" ]; then
                echo "File already exists at ${target_paths[i]}, so skip creating symbolic link"
                continue
            else
                unlink "${target_paths[i]}"
            fi
        fi
        ln -s "${link_paths[i]}" "${target_paths[i]}"
    done
}

setup_dir() {
    # make vimwiki directories
    mkdir -p ~/vimwiki/data/todo
}

cat /dev/null <<EOF
------------------------------------------------------------------------
End of functions
------------------------------------------------------------------------
EOF

parse_args "$@"

check_args

get_os

if [ "$OS" = "amzn" ]; then
    install_dev_libs_for_amzn
elif [ "$OS" = "ubuntu" ]; then
    install_dev_libs_for_ubuntu
elif type sw_vers >/dev/null 2>&1; then
    install_dev_libs_for_mac
else
    echo "[ERROR] '$OS' is not supported"
    exit 1
fi

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

install_deno

create_tmux_user_conf

setup_symbolic_links

setup_dir

echo "Installation completed"
