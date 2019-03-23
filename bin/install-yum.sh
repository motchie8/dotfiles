#!/bin/bash

# install development tools
sudo yum groupinstall "Development Tools" -y
# install libraries for pyenv and neovim 
sudo yum update -y && sudo yum install git xsel zlib-devel bzip2 bzip2-devel readline-devel sqlite sqlite-devel \
openssl-devel xz xz-devel libffi-devel make libtool autoconf automake cmake gcc gcc-c++ make pkgconfig unzip gettext patch ctags -y

# setup pyenv
if ! type pyenv >/dev/null 2>&1; then
  echo "install pyenv"
  curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash
  echo '
  export PATH="$HOME/.pyenv/bin:$PATH"
  export PYENV_PATH=$HOME/.pyenv
  eval "$(pyenv init -)"
  eval "$(pyenv virtualenv-init -)"
  ' >> ~/.bashrc
  source ~/.bashrc
else
  pyenv update
fi

# create envs for neovim by pyenv-virtualenv
pyenv install -s 2.7.16
pyenv install -s 3.6.8
# neovim2
pyenv virtualenv 2.7.16 neovim2
if [ $? -eq 0 ]; then
  pyenv rehash
  source ~/.bashrc
  pyenv activate neovim2
  pip install --upgrade pip
  pip install pynvim
  pip install neovim
  pyenv deactivate
fi
# neovim3
pyenv virtualenv 3.6.8 neovim3
if [ $? -eq 0 ]; then
  pyenv rehash
  source ~/.bashrc
  pyenv activate neovim3
  pip install --upgrade pip
  pip install pynvim
  pip install neovim
  pip install -r ~/.dotfiles/python/requirements.txt
  pyenv deactivate
fi

# setup neovim
if ! type nvim >/dev/null 2>&1; then  
  echo "install neovim"
  cd ~/.dotfiles
  git clone https://github.com/neovim/neovim
  cd neovim
  make clean
  make CMAKE_BUILD_TYPE=RelWithDebInfo
  sudo make install
  sudo ln -s -T /usr/local/bin/nvim /usr/bin/nvim
  mkdir -p ~/.config/nvim
  ln -s -T ~/.vimrc ~/.config/nvim/init.vim
fi

cd ~/.dotfiles
# setup neovim color schema
if [ ! -e ~/.dotfiles/iceberg.vim ]; then
  git clone https://github.com/cocopon/iceberg.vim
  mkdir -p ~/.config/nvim/colors
  ln -s -T ~/.dotfiles/iceberg.vim/colors/iceberg.vim ~/.config/nvim/colors/iceberg.vim
fi

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
  ln -s -T ~/.dotfiles/vim ~/.vim
fi
if [ ! -e ~/.vimrc ]; then
  ln -s -T ~/.dotfiles/.vimrc ~/.vimrc
fi
if [ ! -e ~/.tmux.conf ]; then
  ln -s ~/.dotfiles/.tmux.conf ~/.tmux.conf
fi
#if [ ! -e ~/.globalrc ]; then
#  ln -s -T ~/.dotfiles/.globalrc ~/.globalrc
#fi
source ~/.bashrc
echo "process finished"
