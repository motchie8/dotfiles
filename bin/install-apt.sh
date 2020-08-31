#!/bin/bash

# install libraries for pyenv and neovim
sudo apt update -y && sudo apt install curl build-essential zlib1g-dev libssl-dev libreadline-dev libbz2-dev libsqlite3-dev wget cmake pkg-config unzip libtool libtool-bin m4 automake gettext zsh zplug x11-apps -y

sudo apt install libffi-dev -y

# highlight less
cat ~/.bashrc | grep -q "LESSOPEN"
if [ $? -ne 0 ]; then
  sudo apt install source-highlight -y
  echo "LESS=' -R '" >> ~/.bashrc
  echo "LESSOPEN='| src-hilite-lesspipe.sh %s'" >> ~/.bashrc
fi

# setup pyenv
if ! type pyenv >/dev/null 2>&1; then
  echo "[INFO] install pyenv"
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
# pyenv install -s 3.7.7
pyenv install -s 3.6.10

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
# pyenv virtualenv 3.7.7 neovim3
pyenv virtualenv 3.6.10 neovim3
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
  echo "[INFO] install neovim"
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

# update neovim
cd ~/.dotfiles/neovim
git pull | grep -q "Already up-to-date"
if [ $? -ne 0 ]; then
  echo "[INFO] update neovim"
  git pull
  make distclean
  make CMAKE_BUILD_TYPE=RelWithDebInfo
  sudo make install
fi

cd ~/.dotfiles
# setup color schema
if [ ! -e ~/.dotfiles/iceberg.vim ]; then
  git clone https://github.com/cocopon/iceberg.vim
  mkdir -p ~/.config/nvim/colors
  ln -s -T ~/.dotfiles/iceberg.vim/colors/iceberg.vim ~/.config/nvim/colors/iceberg.vim
  wget -O $HOME/.dotfiles/iceberg.tmux.conf https://raw.githubusercontent.com/gkeep/iceberg-dark/master/.tmux/iceberg.tmux.conf
fi

# color schemas
# git clone https://github.com/flrnd/plastic.vim
# ln -s -T ~/.dotfiles/plastic.vim/colors/plastic.vim ~/.config/nvim/colors/plastic.vim
# git clone https://github.com/flrnd/candid.vim
# ln -s -T ~/.dotfiles/candid.vim/colors/candid.vim ~/.config/nvim/colors/candid.vim
# git clone https://github.com/Rigellute/rigel
# ln -s -T ~/.dotfiles/rigel/colors/rigel.vim ~/.config/nvim/colors/rigel.vim
# git clone https://github.com/sainnhe/edge
# ln -s -T ~/.dotfiles/edge/colors/edge.vim ~/.config/nvim/colors/edge.vim

# setup go
if ! type go > /dev/null 2>&1; then
  wget https://dl.google.com/go/go1.13.3.linux-amd64.tar.gz
  sudo tar -C /usr/local -xzf go1.13.3.linux-amd64.tar.gz
  echo "export PATH=$PATH:/usr/local/go/bin" >> ~/.bashrc
  source ~/.bash_profile
fi

# setup lemonade
if ! type lemonade > /dev/null 2>&1; then
  go get github.com/pocke/lemonade
  cd ~/go/src/github.com/lemonade-command/lemonade/
  make install
  sudo ln -s -T ~/go/bin/lemonade /usr/local/bin/lemonade
fi

# setup aws-cfn-snippet.vim
# git clone https://github.com/lunarxlark/aws-cfn-snippet.vim.git
# rm aws-cloudformation-user-guide -rf
# git clone https://github.com/awsdocs/aws-cloudformation-user-guide.git
# bash make-cfn-snippet.sh
# cp snippets/* ~/.dotfiles/vim/snippets/

# setup coc.nvim
# install nodejs and yarn
if [ ! -x "$(command -v node)" ]; then
    curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
    sudo apt-get install -y nodejs
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
    sudo apt update -y && sudo apt install yarn -y
    # curl --compressed -o- -L https://yarnpkg.com/install.sh | bash
fi
# install coc.nvim
if [ ! -d ~/.local/share/nvim/site/pack/coc ]; then
    mkdir -p ~/.local/share/nvim/site/pack/coc/start
    cd ~/.local/share/nvim/site/pack/coc/start
    curl --fail -L https://github.com/neoclide/coc.nvim/archive/release.tar.gz | tar xzfv -
    ln -s ~/.dotfiles/coc-settings.json ~/.config/nvim/coc-settings.json
    cd ~/.dotfiles
fi


# install fzf
if [ ! -d ~/.fzf ]; then
  git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
  ~/.fzf/install --all
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
if [ ! -e ~/.config/lemonade.toml ]; then
  mkdir -p ~/.config
  ln -s ~/.dotfiles/lemonade.toml ~/.config/lemonade.toml
fi
#if [ ! -e ~/.globalrc ]; then
#  ln -s -T ~/.dotfiles/.globalrc ~/.globalrc
#fi
source ~/.bashrc
echo "[INFO] process finished"
