#!/bin/zsh

# install brew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

# install packages
brew update
brew install node yarn wget tmux go

# highlight less
cat ~/.zshrc | grep -q "LESSOPEN"
if [ $? -ne 0 ]; then
  brew install source-highlight
  echo "LESS=' -R '" >> ~/.zshrc
  echo "LESSOPEN='| src-hilite-lesspipe.sh %s'" >> ~/.zshrc
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
  ' >> ~/.zshrc
  source ~/.zshrc
else
  brew update pyenv
fi

# create envs for neovim by pyenv-virtualenv
pyenv install -s 2.7.18
pyenv install -s 3.7.7
# neovim2
pyenv virtualenv 2.7.18 neovim2
if [ $? -eq 0 ]; then
  pyenv rehash
  source ~/.zshrc
  pyenv activate neovim2
  pip install --upgrade pip
  pip install pynvim
  pip install neovim
  pyenv deactivate
fi
# neovim3
pyenv virtualenv 3.7.7 neovim3
if [ $? -eq 0 ]; then
  pyenv rehash
  source ~/.zshrc
  pyenv activate neovim3
  pip install --upgrade pip
  pip install pynvim
  pip install neovim
  pip install -r ~/.dotfiles/python/requirements.txt
  pyenv deactivate
fi

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

# setup go
# if ! type go > /dev/null 2>&1; then
#   wget https://dl.google.com/go/go1.13.3.linux-amd64.tar.gz
#   sudo tar -C /usr/local -xzf go1.13.3.linux-amd64.tar.gz
#   echo "export PATH=$PATH:/usr/local/go/bin" >> ~/.zshrc
#   source ~/.bash_profile
# fi

# setup lemonade
# if ! type lemonade > /dev/null 2>&1; then
#   go get github.com/pocke/lemonade
#   cd ~/go/src/github.com/lemonade-command/lemonade/
#   make install
#   sudo ln -s -T ~/go/bin/lemonade /usr/local/bin/lemonade
# fi

# setup aws-cfn-snippet.vim
# git clone https://github.com/lunarxlark/aws-cfn-snippet.vim.git
# rm aws-cloudformation-user-guide -rf
# git clone https://github.com/awsdocs/aws-cloudformation-user-guide.git
# bash make-cfn-snippet.sh
# cp snippets/* ~/.dotfiles/vim/snippets/

# setup coc.nvim
ln -s ~/.dotfiles/coc-settings.json ~/.config/nvim/coc-settings.json

# for coc-nvim extension's dependency
go get github.com/mattn/efm-langserver

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
fi
if [ ! -e ~/.config/lemonade.toml ]; then
  mkdir -p ~/.config
  ln -s ~/.dotfiles/lemonade.toml ~/.config/lemonade.toml
fi

source ~/.zshrc
echo "[INFO] process finished"
