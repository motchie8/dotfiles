# docker build -f docker/ubuntu/Dockerfile -t motchie8/dotfiles:master .
FROM ubuntu:22.04

# Setup ubuntu user
ARG user=ubuntu
ARG sudogroup=sudo
RUN useradd $user -m && gpasswd -a $user $sudogroup
RUN mkdir -p /etc/sudoers.d && echo "$user ALL=(ALL:ALL) NOPASSWD: ALL" | tee /etc/sudoers.d/$user
RUN apt update -y && apt install -y sudo

# Change user and workdir
USER $user
WORKDIR /home/$user/dotfiles

# Install development libs
COPY --chown=$user:$user bin /home/$user/dotfiles/bin
COPY --chown=$user:$user python /home/$user/dotfiles/python
COPY --chown=$user:$user tmux /home/$user/dotfiles/tmux
RUN ./bin/install.sh -b -t b

# Copy other settings
COPY --chown=$user:$user snippets /home/$user/dotfiles/snippets
COPY --chown=$user:$user vscode /home/$user/dotfiles/vscode
COPY --chown=$user:$user \
    .vimspector.json \
    .zshrc \
    cheatsheet.txt \
    coc-settings.json \
    init.lua \
    /home/$user/dotfiles/
# Setup symbolic links
RUN ./bin/setup_symbolic_links.sh

# Install Neovim plugins
RUN nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync' \
    && nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'
