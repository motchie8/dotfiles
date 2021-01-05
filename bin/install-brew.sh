#!/bin/bash

RC_SCRIPT=zshrc
ln -s ~/.$RC_SCRIPT ~/.dotfiles/.$RC_SCRIPT

OS=$(cat /etc/os-release | grep -E '^ID="[^"]*"$' | tr -d '"' | awk -F '[=]' '{print $NF}')
# install brew
if ! type brew >/dev/null 2>&1; then
  echo "[INFO] Install Homebrew"
  if [ "$OS" = "centos" ] || [ "$OS" = "amzn" ]; then
    sudo yum groupinstall 'Development Tools' -y
    sudo yum install curl file git -y
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)" 
    # TODO add brew to PATH
  elif [ "$OS" = "ubuntu"]; then
    sudo apt update -y && sudo apt-get install build-essential curl file git -y
    echo 'eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)' >> ~/.zprofile
    brew install gcc
  else
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
  fi
  eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
  brew install gcc
fi

# install libraries
brew update
brew install node yarn wget tmux go zsh zplug fzf

# setup zsh
DEFAULT_SHELL=$(echo $SHELL | awk -F '[/]' '{print $NF}')
if [ "$DEFAULT_SHELL" != "zsh" ]; then
  chsh -s /home/linuxbrew/.linuxbrew/bin/zsh
fi

# install zprezto
if [ ! -e $HOME/.dotfiles/.zprezto ]; then
  echo "[INFO] Install zprezto"
  zsh
  git clone --recursive https://github.com/sorin-ionescu/prezto.git ~/.dotfiles/.zprezto
  setopt EXTENDED_GLOB
  for rcfile in $HOME/.dotfiles/.zprezto/runcoms/^README.md(.N); do
    rcfile_name="."$(echo $rcfile | awk -F '[/]' '{print $NF}')
    if [ ! -e $HOME/$rcfile_name ]; then
      ln -s "$rcfile" "$HOME/$rcfile_name" 
    fi
  done
fi

# highlight less
cat ~/.$RC_SCRIPT | grep -q "LESSOPEN"
if [ $? -ne 0 ]; then
  brew install source-highlight
  echo "LESS=' -R '" >> ~/.$RC_SCRIPT
  echo "LESSOPEN='| src-hilite-lesspipe.sh %s'" >> ~/.$RC_SCRIPT
fi

# setup pyenv
if ! type pyenv >/dev/null 2>&1; then
  echo "[INFO] install pyenv"
  brew install pyenv pyenv-virtualenv
  echo '
  export PATH="$HOME/.pyenv/bin:$PATH"
  export PYENV_PATH=$HOME/.pyenv
  eval "$(pyenv init -)"
  eval "$(pyenv virtualenv-init -)"
  ' >> ~/.$RC_SCRIPT
  source ~/.$RC_SCRIPT
else
  brew update pyenv
fi

# create envs for neovim by pyenv-virtualenv
PYTHON2_VERSION=2.7.18
PYTHON3_VERSION=3.7.7
PYTHON_VERSIONS=($PYTHON2_VERSION $PYTHON3_VERSION)
NEOVIM_VIRTUAL_ENVS=("neovim2" "neovim3")
i=0
for PYTHON_VERSION in "${PYTHON_VERSIONS[@]}" 
do
  NEOVIM_VIRTUAL_ENV=${NEOVIM_VIRTUAL_ENVS[i]}
  pyenv versions | grep -q $PYTHON_VERSION
  if [ $? -ne 0 ]; then
    pyenv install -s $PYTHON_VERSION
    pyenv virtualenv $PYTHON_VERSION $NEOVIM_VIRTUAL_ENV
    pyenv rehash
    source ~/.$RC_SCRIPT
    pyenv activate $NEOVIM_VIRTUAL_ENV
    pip install --upgrade pip
    pip install pynvim
    pip install neovim
    if [ "$NEOVIM_VIRTUAL_ENV" = "neovim3" ]; then
      pip install -r ~/.dotfiles/python/requirements.txt
    fi
    pyenv deactivate
    let i++
  fi
done

# setup neovim
if ! type nvim >/dev/null 2>&1; then  
  echo "[INFO] install neovim"
  brew install neovim
  mkdir -p ~/.config/nvim
  ln -s ~/.vimrc ~/.config/nvim/init.vim
fi

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
if [ ! -e ~/.config/nvim/coc-settings.json ]; then
  ln -s ~/.dotfiles/coc-settings.json ~/.config/nvim/coc-settings.json
fi
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
if [ ! -e ~/.vim ]; then
  ln -s ~/.dotfiles/vim ~/.vim
fi
if [ ! -e ~/.vimrc ]; then
  ln -s ~/.dotfiles/.vimrc ~/.vimrc
fi
if [ ! -e ~/.tmux.conf ]; then
  ln -s ~/.dotfiles/.tmux.conf ~/.tmux.conf
  # ln -s ~/.dotfiles/.tmux.host.conf ~/.tmux.conf
fi
# if [ ! -e ~/.config/lemonade.toml ]; then
#   mkdir -p ~/.config
#   ln -s ~/.dotfiles/lemonade.toml ~/.config/lemonade.toml
# fi

source ~/.$RC_SCRIPT
echo "[INFO] process finished"
