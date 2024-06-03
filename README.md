# dotfiles

This repository contains my personal collection of configuration files.

## Requirements 

* The supported operating systems are MacOS and Ubuntu.


## Installation

Install the necessary libraries for the development environment.

```sh
$ make install
```

Use the following script to run the installation script with custom options.

```sh
$ ./bin/install.sh -h
Usage: ./bin/install.sh -t TMUX_PREFIX_KEY
  -h                    Show this help message and exit
  -b                    Build Neovim from source
  -t TMUX_PREFIX_KEY    Specify prefix Key for tmux. For example, "-t b"
```

### Optional

Set up TaskWarrior for file synchronization. GCS bucket and a GCP service account are required. Copy `.env.example` to create `.env` and set your variables.

```sh
$ make install-tasksync
```

Set up the system to mount Google Drive. Currently, only Ubuntu is supported.
```sh
$ make install-google-drive-fuse
```

## Configuration

Custom settings are read from environment variables. Copy `.env.example` to create `.env`, and set your variables.

## Docker Image

Docker image is available on Docker Hub. The image is built from the `master` branch. Currently, only the Ubuntu image is available.

```sh
$ docker run -it --rm -v $(pwd):/mnt/host motchie8/dotfiles:master zsh
```

### Build Image
Build the docker image locally.

```sh
$ make build
`````
