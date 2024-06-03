# docker build -f docker/ubuntu/Dockerfile -t motchie8/dotfiles:master .
FROM ubuntu:24.04

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

# Install development libs first to use cache
COPY --chown=$user:$user \
    bin/setup_deb_libs.sh \
    bin/common.sh \
    /home/$user/dotfiles/bin/
RUN ./bin/setup_deb_libs.sh

COPY --chown=$user:$user bin /home/$user/dotfiles/bin
COPY --chown=$user:$user python /home/$user/dotfiles/python
COPY --chown=$user:$user tmux /home/$user/dotfiles/tmux
COPY --chown=$user:$user Makefile /home/$user/dotfiles/Makefile
RUN make install

# Copy other settings
COPY --chown=$user:$user snippets /home/$user/dotfiles/snippets
COPY --chown=$user:$user vscode /home/$user/dotfiles/vscode
COPY --chown=$user:$user lua /home/$user/dotfiles/lua
COPY --chown=$user:$user dap /home/$user/dotfiles/dap
COPY --chown=$user:$user \
    .vimspector.json \
    .zshrc \
    cheatsheet.txt \
    coc-settings.json \
    init.lua \
    /home/$user/dotfiles/

# Install Neovim plugins
RUN nvim --headless "+Lazy! sync" +qa
