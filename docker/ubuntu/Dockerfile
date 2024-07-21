FROM ubuntu:24.04

# Set BUILD_FROM_SOURCE to true to build libs from source e.g. neovim, cmake, taskwarrior
ARG BUILD_FROM_SOURCE=false

# Setup ubuntu user
ARG user=ubuntu
ARG sudogroup=sudo
# RUN useradd $user -m && gpasswd -a $user $sudogroup
RUN gpasswd -a $user $sudogroup
RUN mkdir -p /etc/sudoers.d && echo "$user ALL=(ALL:ALL) NOPASSWD: ALL" | tee /etc/sudoers.d/$user
RUN apt update -y && apt install -y sudo

# Change user and workdir
USER $user
WORKDIR /home/$user/dotfiles

# Install essential libs for the first utilize cache layer
COPY --chown=$user:$user \
    bin/install_essentials.sh \
    bin/common.sh \
    /home/$user/dotfiles/bin/
RUN if [ "$BUILD_FROM_SOURCE" = "true" ]; then \
        /home/$user/dotfiles/bin/install_essentials.sh -b; \
    else \
        /home/$user/dotfiles/bin/install_essentials.sh; \
    fi

COPY --chown=$user:$user bin /home/$user/dotfiles/bin
COPY --chown=$user:$user python /home/$user/dotfiles/python
COPY --chown=$user:$user tmux /home/$user/dotfiles/tmux
COPY --chown=$user:$user Makefile /home/$user/dotfiles/Makefile
RUN if [ "$BUILD_FROM_SOURCE" = "true" ]; then \
        make install-base-from-source; \
    else \
        make install-base-by-package-manager; \
    fi

# Copy other settings in alphabetical order
COPY --chown=$user:$user config /home/$user/dotfiles/config
COPY --chown=$user:$user dap /home/$user/dotfiles/dap
COPY --chown=$user:$user lua /home/$user/dotfiles/lua
COPY --chown=$user:$user snippets /home/$user/dotfiles/snippets
COPY --chown=$user:$user vscode /home/$user/dotfiles/vscode
COPY --chown=$user:$user \
    .vimspector.json \
    .zshrc \
    cheatsheet.txt \
    coc-settings.json \
    init.lua \
    /home/$user/dotfiles/

# Install Neovim plugins
RUN nvim --headless "+Lazy! sync" +qa
