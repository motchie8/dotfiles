#!/bin/bash
set -eux

RC_SCRIPT=zshrc
if [ ! -L ~/.$RC_SCRIPT ]; then
  ln -s ~/.dotfiles/.$RC_SCRIPT ~/.$RC_SCRIPT
fi
OS=$(cat /etc/os-release | grep -E '^ID="[^"]*"$' | tr -d '"' | awk -F '[=]' '{print $NF}')
# install brew
if ! type brew >/dev/null 2>&1; then
  echo "[INFO] Install Homebrew"
  if [ ${EUID:-${UID}} = 0 ]; then
    echo "[ERROR] Homebrew cannot be installed using root user. Change user and revoke script."
    echo "User creation command example: 'USERNAME="ec2-user" && useradd -m \$USERNAME && usermod -aG wheel \$USERNAME && su \$USERNAME'"
    exit 1
  fi
  # install using non-interactive mode
  export CI=1
  if [ "$OS" = "centos" ] || [ "$OS" = "amzn" ]; then
    sudo yum groupinstall 'Development Tools' -y
    sudo yum install curl file git util-linux-user which ruby -y
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)" 
    # TODO add brew to PATH
  elif [ "$OS" = "ubuntu"]; then
    sudo apt update -y && sudo apt-get install build-essential curl file git -y
    echo 'eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)' >> ~/.zprofile
    brew install gcc
  else
    echo "[WARNING] install dependencies manually if needed"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)" 
  fi
  eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
  brew install gcc
fi

# install libraries by brew
brew update
set +e
brew install node yarn wget tmux go zsh zplug fzf source-highlight pyenv neovim pyenv-virtualenv
set -e

# setup zsh
DEFAULT_SHELL=$(echo $SHELL | awk -F '[/]' '{print $NF}')
if [ "$DEFAULT_SHELL" != "zsh" ]; then
  output=$(cat /etc/shells | grep -q "zsh") || result=$?
  if [ $result -ne 0 ]; then
    echo "/home/linuxbrew/.linuxbrew/bin/zsh" >> /etc/shells
  fi
  chsh -s /home/linuxbrew/.linuxbrew/bin/zsh
fi

# install zprezto
if [ ! -e $HOME/.dotfiles/.zprezto ]; then
  echo "[INFO] Install zprezto"
  git clone --recursive https://github.com/sorin-ionescu/prezto.git ~/.dotfiles/.zprezto
  for rcfile_name in zlogin zlogout zpreztorc zprofile zshenv; do
    if [ ! -e $HOME/$rcfile_name ]; then
      ln -s "$HOME/.dotfiles/.zprezto/runcoms/.$rcfile" "$HOME/.$rcfile_name" 
    fi
  done
fi

# setup pyenv
# export PATH="$HOME/.pyenv/bin:$PATH"
# export PYENV_PATH=$HOME/.pyenv

# create envs for neovim by pyenv-virtualenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if which pyenv > /dev/null; then
  eval "$(pyenv init -)" 
fi
# set env to avoid errors in pyenv/virtualenv init
export PROMPT_COMMAND=""
export PYENV_VIRTUALENV_DISABLE_PROMPT=1
eval "$(pyenv virtualenv-init -)"
export _OLD_VIRTUAL_PATH=""
export _OLD_VIRTUAL_PYTHONHOME=""
export _OLD_VIRTUAL_PS1=""

PYTHON2_VERSION=2.7.18
PYTHON3_VERSION=3.8.3
PYTHON_VERSIONS=($PYTHON2_VERSION $PYTHON3_VERSION)
NEOVIM_VIRTUAL_ENVS=("neovim2" "neovim3")
i=0
for PYTHON_VERSION in "${PYTHON_VERSIONS[@]}" 
do
  pyenv install -s $PYTHON_VERSION
  NEOVIM_VIRTUAL_ENV=${NEOVIM_VIRTUAL_ENVS[i]}
  result=0
  output=$(pyenv versions | grep -q $NEOVIM_VIRTUAL_ENV) || result=$?
  if [ $result -ne 0 ]; then 
    pyenv virtualenv $PYTHON_VERSION $NEOVIM_VIRTUAL_ENV
    pyenv rehash
    pyenv activate $NEOVIM_VIRTUAL_ENV
    pip install --upgrade pip
    pip install pynvim neovim
    if [ "$NEOVIM_VIRTUAL_ENV" = "neovim3" ]; then
      pip install -r ~/.dotfiles/python/requirements.txt
    fi
    pyenv deactivate
  fi
  i=$(expr $i + 1)
done

cd ~/.dotfiles
# setup color schema
if [ ! -e ~/.dotfiles/iceberg.vim ]; then
  git clone https://github.com/cocopon/iceberg.vim
  mkdir -p ~/.config/nvim/colors
  ln -s ~/.dotfiles/iceberg.vim/colors/iceberg.vim ~/.config/nvim/colors/iceberg.vim
  wget -O $HOME/.dotfiles/iceberg.tmux.conf https://raw.githubusercontent.com/gkeep/iceberg-dark/master/.tmux/iceberg.tmux.conf
fi

# setup aws-cfn-snippet.vim
# git clone https://github.com/lunarxlark/aws-cfn-snippet.vim.git
# rm aws-cloudformation-user-guide -rf
# git clone https://github.com/awsdocs/aws-cloudformation-user-guide.git
# bash make-cfn-snippet.sh
# cp snippets/* ~/.dotfiles/vim/snippets/

# setup coc.nvim
# for coc-nvim extension's dependency
# go get github.com/mattn/efm-langserver

# install gtags
#if ! type gtags >/dev/null 2>&1; then
#  echo "install gtags"
#  wget http://tamacom.com/global/global-6.6.3.tar.gz
#  tar xzvf global-6.6.3.tar.gz
#  cd global-6.6.3/
#  ./configure
#  make CFLAGS="-std=gnu99"
#  sudo make install
#  pyenv activate neovim3
#  pip install pygments
#  pyenv deactivate
#fi

# symbolic links
if [ ! -L ~/.zshrc ]; then
  ln -s ~/.dotfiles/.zshrc ~/.zshrc
fi 
if [ ! -L ~/.vim ]; then
  ln -s ~/.dotfiles/vim ~/.vim
fi
if [ ! -L ~/.vimrc ]; then
  ln -s ~/.dotfiles/.vimrc ~/.vimrc
fi
if [ ! -e ~/.config/nvim ]; then
  mkdir -p ~/.config/nvim 
  ln -s ~/.vimrc ~/.config/nvim/init.vim
fi
if [ ! -L ~/.tmux.conf ]; then
  ln -s ~/.dotfiles/.tmux.conf ~/.tmux.conf
  # ln -s ~/.dotfiles/.tmux.host.conf ~/.tmux.conf
fi
if [ ! -L ~/.config/nvim/coc-settings.json ]; then
  ln -s ~/.dotfiles/coc-settings.json ~/.config/nvim/coc-settings.json
fi
# if [ ! -L ~/.config/lemonade.toml ]; then
#   mkdir -p ~/.config
#   ln -s ~/.dotfiles/lemonade.toml ~/.config/lemonade.toml
# fi
echo "[INFO] process finished"
