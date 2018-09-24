#!/bin/bash

#yum install -y wget
#wget https://bootstrap.pypa.io/get-pip.py
#python get-pip.py
#yum install -y https://centos7.iuscommunity.org/ius-release.rpm
#yum install -y python35u python35u-libs python35u-devel python35u-pip
#ln -s -T /usr/bin/python3.5 /usr/bin/python3
#ln -s -T /usr/bin/pip3.5 /usr/bin/pip3

# libs for pyenv 
sudo yum install git zlib-devel bzip2 bzip2-devel readline-devel sqlite sqlite-devel \
openssl-devel xz xz-devel libffi-devel make libtool autoconf automake cmake gcc gcc-c++ make pkgconfig unzip gettext -y
# pyenv
curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash
echo '
export PATH="$HOME/.pyenv/bin:$PATH"
export PYENV_PATH=$HOME/.pyenv
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
' >> ~/.bash_profile
source ~/.bash_profile

# pyenv-virtualenv
#git clone https://github.com/pyenv/pyenv-virtualenv.git $(pyenv root)/plugins/pyenv-virtualenv
# create envs for neovim
pyenv install 2.7.15
pyenv install 3.5.6
pyenv virtualenv 2.7.15 neovim2
pyenv virtualenv 3.5.6 neovim3
# install neovim plugins
pyenv shell neovim3
pip install -U pip
pip install -U -r ~/.dotfiles/python/requirements.txt
#pyenv global 3.5.6
#pyenv rehash
# create symbolic links for nvim pyenv
ln -s `pyenv which flake8` ~/.pyenv/bin/flake8
#ln -s `pyenv which flake8-import-order` ~/.pyenv/bin/flake8-import-order
ln -s `pyenv which autopep8` ~/.pyenv/bin/autopep8
#ln -s `pyenv which jedi` ~/.pyenv/bin/jedi
ln -s `pyenv which isort` ~/.pyenv/bin/isort

# install neovim
#sudo yum -y install libtool autoconf automake cmake gcc gcc-c++ make pkgconfig unzip
cd ~/.dotfiles
git clone https://github.com/neovim/neovim
cd neovim
make
sudo make install
sudo ln -s -T /usr/local/bin/nvim /usr/bin/nvim
# setup neovim color schema
#mkdir ~/.vim
#mkdir ~/.vim/rc
cd ~/.dotfiles
git clone https://github.com/cocopon/iceberg.vim
#mv iceberg.vim/colors ~/.dotfiles/vim/colors

# setupo symbolic links
ln -s -T ~/.dotfiles/vim ~/.vim
ln -s -T ~/.dotfiles/.vimrc ~/.vimrc
mkdir -p ~/.config/nvim
ln -s -T ~/.vimrc ~/.config/nvim/init.vim
ln -s ~/.dotfiles/.tmux.conf ~/.tmux.conf
mkdir -p ~/.vim/colors
ln -s -T ~/.dotfiles/iceberg.vim/colors/iceberg.vim ~/.vim/colors/iceberg.vim
source ~/.bash_profile
#mkdir -p ~/.config/nvim
#mkdir ~/.vim
#ln -s ~/.vim ~/.config/nvim
#ln -s ~/.vimrc ~/.config/nvim/init.vim
