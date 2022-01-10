#!/bin/bash
# install libraries for each OS
set -eux

OS=$(cat /etc/os-release | grep -E '^ID="?[^"]*"?$' | tr -d '"' | awk -F '[=]' '{print $NF}')

if [ "$OS" = "centos" ] || [ "$OS" = "amzn" ]; then
    echo "[INFO] Install libraries for $OS"
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
      patch ctags zsh wget util-linux-user
    # install xclip
    sudo amazon-linux-extras install epel -y
    sudo yum-config-manager --enable epel
    sudo yum install xclip -y
    # install neovim prerequisites
    sudo yum -y install ninja-build libtool autoconf automake \
        gcc gcc-c++ make pkgconfig unzip patch gettext curl
    # install cmake v3 for nvim
    if [ ! -e ~/.dotfiles/cmake-3.22.1 ]; then
	# uninstall cmake v2
	sudo yum remove cmake -y
        pushd ~/.dotfiles
        wget https://cmake.org/files/v3.22/cmake-3.22.1.tar.gz
        tar -xvzf cmake-3.22.1.tar.gz
        pushd cmake-3.22.1
        ./bootstrap
        make
        sudo make install
        popd
        popd
    fi
    
    # install neovim
    if ! type nvim >/dev/null 2>&1; then  
        echo "[INFO] install neovim for $OS"
        pushd ~/.dotfiles
        git clone https://github.com/neovim/neovim
        popd
        pushd ~/.dotfiles/neovim
        make clean
        make CMAKE_BUILD_TYPE=RelWithDebInfo
        sudo make install
        sudo ln -s -T /usr/local/bin/nvim /usr/bin/nvim 
        popd
    fi
    # update neovim
    pushd ~/.dotfiles/neovim
    result=0
    output=$(git pull | grep -q "Already up to date") || result=$?
    if [ $result -ne 0 ]; then
        echo "[INFO] update neovim"
        git pull
        sudo make distclean
        make CMAKE_BUILD_TYPE=RelWithDebInfo
        sudo make install
    fi
    popd
    # install homebrew
    # sudo yum install -y curl file git util-linux-user which ruby  
elif [ "$OS" = "ubuntu" ]; then
    echo "[INFO] Install libraries for $OS"
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
    # install zsh, pyenv and vim plugin dependencies
    sudo apt install -y curl git file zlib1g-dev libssl-dev \
      libreadline-dev libbz2-dev libsqlite3-dev wget cmake \
      pkg-config unzip libtool libtool-bin m4 automake gettext \
      zsh x11-apps libffi-dev yarn
    # install neovim nightly
    # NOTE: nvim-treesitter needs Neovim nightly
    sudo add-apt-repository -y ppa:neovim-ppa/unstable  # ppa:neovim-ppa/stable
    sudo apt-get update -y && sudo apt-get install -y neovim
elif type sw_vers >/dev/null 2>&1; then
   echo "[INFO] Install libraries for macOS"
   brew update
   set +e
   # install pyenv, vim plugins and zsh
   brew install node yarn wget tmux go zsh fzf source-highlight gcc cmake # pyenv pyenv-virtualenv
   # install neovim nightly
   brew install --HEAD luajit
   brew install --HEAD neovim 
   set -e
else
    echo "[ERROR] '$OS' is not supported"
    exit 1
fi

# install or update pyenv and pyenv-virtualenv
if ! type pyenv >/dev/null 2>&1; then
    echo "[INFO] install pyenv"
    curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash
    # exec $SHELL -l
    export PATH="$HOME/.pyenv/bin:$PATH"
    export PYENV_PATH=$HOME/.pyenv
    export PROMPT_COMMAND=""
    export PYENV_VIRTUALENV_DISABLE_PROMPT=1
    export _OLD_VIRTUAL_PATH=""
    export _OLD_VIRTUAL_PYTHONHOME=""
    export _OLD_VIRTUAL_PS1=""
    eval "$(pyenv init --path)"
    eval "$(pyenv virtualenv-init -)"
elif type brew >/dev/null 2>&1; then
    brew upgrade pyenv
else
    pyenv update
fi

# create envs and install python versions for neovim by pyenv-virtualenv
PYENV_ROOT="$HOME/.pyenv"
PYTHON2_VERSION=2.7.18
PYTHON3_VERSION=3.9.7
PYTHON_VERSIONS=($PYTHON2_VERSION $PYTHON3_VERSION)
NEOVIM_VIRTUAL_ENVS=("neovim2" "neovim3")
i=0
for PYTHON_VERSION in "${PYTHON_VERSIONS[@]}" 
do
    NEOVIM_VIRTUAL_ENV=${NEOVIM_VIRTUAL_ENVS[i]}
    result=0
    output=$(pyenv versions | grep -q $NEOVIM_VIRTUAL_ENV) || result=$?
    if [ $result -ne 0 ]; then 
        pyenv install -s $PYTHON_VERSION
        pyenv virtualenv $PYTHON_VERSION $NEOVIM_VIRTUAL_ENV
        PYTHON_PATH=$PYENV_ROOT/versions/$NEOVIM_VIRTUAL_ENV/bin/python
        eval "$PYTHON_PATH -m pip install --upgrade pip"
        eval "$PYTHON_PATH -m pip install pynvim neovim"
        if [ "$NEOVIM_VIRTUAL_ENV" = "neovim3" ]; then
            eval "$PYTHON_PATH -m pip install -r ~/.dotfiles/python/requirements.txt"
        fi
    fi
    i=$(expr $i + 1)
done

# set zsh as default shell
DEFAULT_SHELL=$(echo $SHELL | awk -F '[/]' '{print $NF}')
if [ "$DEFAULT_SHELL" != "zsh" ]; then
    result=$(cat /etc/shells | grep -q "zsh")
    echo "[INFO] Change default shell to zsh"
    if [ $? -ne 0 ]; then
        echo $(which zsh) >> /etc/shells
    fi
    sudo chsh -s $(which zsh) $(whoami)
fi

# install zplug
if [ ! -e $HOME/.dotfiles/.zplug ]; then
    echo "[INFO] Install zplug"
    export ZPLUG_HOME=$HOME/.dotfiles/.zplug
    git clone https://github.com/zplug/zplug $ZPLUG_HOME
fi


# install zprezto and setup zsh dotfiles
if [ ! -e $HOME/.dotfiles/.zprezto ]; then
    echo "[INFO] Install zprezto"
    git clone --recursive https://github.com/sorin-ionescu/prezto.git ~/.dotfiles/.zprezto
    for rcfile_name in zlogin zlogout zpreztorc zprofile zshenv; do
        if [ ! -e $HOME/$rcfile_name ]; then
            ln -s "$HOME/.dotfiles/.zprezto/runcoms/.$rcfile_name" "$HOME/.$rcfile_name" 
        fi
    done
fi

# download color schema for vim
if [ ! -e ~/.dotfiles/iceberg.vim ]; then
  echo "[INFO] Install color schema"
  pushd ~/.dotfiles
  git clone https://github.com/cocopon/iceberg.vim
  mkdir -p ~/.config/nvim/colors
  ln -s ~/.dotfiles/iceberg.vim/colors/iceberg.vim ~/.config/nvim/colors/iceberg.vim
  wget -O $HOME/.dotfiles/iceberg.tmux.conf https://raw.githubusercontent.com/gkeep/iceberg-dark/master/.tmux/iceberg.tmux.conf
  popd
else
  pushd ~/.dotfiles/iceberg.vim
  git pull
  popd
fi

# install or update npm and node for coc-nvim
if ! type node > /dev/null 2>&1; then
    echo "[INFO] Install node"
    # curl -sL install-node.now.sh/lts | bash
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
    nvm install node --lts
    # nvm use --lts
fi

# install tmux-mem-cpu-load
if [ ! -e ~/.dotfiles/tmux/tmux-mem-cpu-load ]; then
    git clone https://github.com/thewtex/tmux-mem-cpu-load.git ~/.dotfiles/tmux/tmux-mem-cpu-load
    pushd ~/.dotfiles/tmux/tmux-mem-cpu-load
    cmake .
    make
    if type sw_vers >/dev/null 2>&1; then
        make install
    else
	sudo make install
    fi
    popd
fi

# install go
if ! type go > /dev/null 2>&1; then
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

# install git-appraise
go get github.com/google/git-appraise/git-appraise
# install act for github actions
go install github.com/nektos/act@latest
    
# NOTE: Commented out because it is not currently in use
## install lemonade to copy text from Linux to Windows via SSH
#if ! type lemonade > /dev/null 2>&1; then
#  go get github.com/pocke/lemonade
#  cd ~/go/src/github.com/lemonade-command/lemonade/
#  make install
#  sudo ln -s -T ~/go/bin/lemonade /usr/local/bin/lemonade
#fi

## install fzf
#if [ ! -d ~/.fzf ]; then
#  git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
#  ~/.fzf/install --all
#fi

# setup symbolic links
if [ ! -L ~/.zshrc ]; then
  ln -s ~/.dotfiles/.zshrc ~/.zshrc
fi 
if [ ! -L ~/.vim ]; then
  ln -s ~/.dotfiles/vim ~/.vim
fi
if [ ! -L ~/.vimrc ]; then
  ln -s ~/.dotfiles/.vimrc ~/.vimrc
fi
if [ ! -L ~/.config/nvim/init.vim ]; then
  mkdir -p ~/.config/nvim 
  ln -s ~/.vimrc ~/.config/nvim/init.vim
fi
if [ ! -L ~/.tmux.conf ]; then
  ln -s ~/.dotfiles/.tmux.conf ~/.tmux.conf
  # NOTE: tmux config for SSH host client to avoid hotkeys to duplicate
  # ln -s ~/.dotfiles/.tmux.host.conf ~/.tmux.conf
fi
if [ ! -L ~/.config/nvim/coc-settings.json ]; then
  ln -s ~/.dotfiles/coc-settings.json ~/.config/nvim/coc-settings.json
fi

echo "[INFO] Finished"
