# .dotfiles
Setup script and dotfiles for development environment with neovim, zsh and pyenv.

## Install
Install development tools and create symbolic links for dotfiles.  
Intented for use with Ubuntu, MacOS or AmazonLinux.
```
$ ./bin/install.sh
```

## Docker
The installed environment can be used as a Docker container.
```
$ docker run -it --rm motchie8/dotfiles:ubuntu zsh
```
