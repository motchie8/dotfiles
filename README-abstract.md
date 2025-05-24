# dotfiles

This repository contains a collection of configuration files for MacOS and Ubuntu.

## Installation

Install necessary libraries for the development environment using `make install`.

### Optional

*   Install TaskWarrior with `make install-taskwarrior`.
*   Set up TaskWarrior file synchronization with GCS (requires `.env` configuration) using `make install-tasksync`.
*   Set up Google Drive mounting on Ubuntu using `make install-google-drive-fuse`.

## Configuration

Custom settings are read from environment variables. Configure `.env` file.

## Docker Image

A Docker image is available on Docker Hub, built from the `master` branch (Ubuntu).

```sh
$ docker run -it --rm -v $(pwd):/mnt/host motchie8/dotfiles:master zsh
```

### Build Image

Build the docker image locally using `make build`.
