#!/bin/bash

# args to specify python version to install
for OPT in "$@"
do
    case $OPT in
        '-p' )
            PYTHON_FLAG=1
	    PYTHON_VERSION=$2
	    shift 2
            ;;
    esac
    shift
done

# install libs for pyenv 
sudo yum install git zlib-devel bzip2 bzip2-devel readline-devel sqlite sqlite-devel \
openssl-devel xz xz-devel libffi-devel make libtool autoconf automake cmake gcc gcc-c++ make pkgconfig unzip gettext -y
# install pyenv
curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash
echo '
export PATH="$HOME/.pyenv/bin:$PATH"
export PYENV_PATH=$HOME/.pyenv
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
' >> ~/.bash_profile
source ~/.bash_profile

# create envs for neovim
if [ "$PYTHON_FLAG" ]; then
    pyenv install $PYTHON_VERSION
    pyenv virtualenv $PYTHON_VERSION neovim3
else
    pyenv install 2.7.15
    pyenv install 3.5.6
    pyenv virtualenv 2.7.15 neovim2
    pyenv virtualenv 3.5.6 neovim3
fi

# install neovim plugins
pyenv shell neovim3
pip install -U pip
pip install -U -r ~/.dotfiles/python/requirements.txt
# create symbolic links for nvim pyenv
ln -s `pyenv which flake8` ~/.pyenv/bin/flake8
#ln -s `pyenv which flake8-import-order` ~/.pyenv/bin/flake8-import-order
ln -s `pyenv which autopep8` ~/.pyenv/bin/autopep8
#ln -s `pyenv which jedi` ~/.pyenv/bin/jedi
ln -s `pyenv which isort` ~/.pyenv/bin/isort

# install neovim
cd ~/.dotfiles
git clone https://github.com/neovim/neovim
cd neovim
make
sudo make install
sudo ln -s -T /usr/local/bin/nvim /usr/bin/nvim
# color schema
cd ~/.dotfiles
git clone https://github.com/cocopon/iceberg.vim

# symbolic links
ln -s -T ~/.dotfiles/vim ~/.vim
ln -s -T ~/.dotfiles/.vimrc ~/.vimrc
mkdir -p ~/.config/nvim
ln -s -T ~/.vimrc ~/.config/nvim/init.vim
ln -s ~/.dotfiles/.tmux.conf ~/.tmux.conf
mkdir -p ~/.vim/colors
ln -s -T ~/.dotfiles/iceberg.vim/colors/iceberg.vim ~/.vim/colors/iceberg.vim
source ~/.bash_profile
