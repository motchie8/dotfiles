# docker build . -f docker/ubuntu/Dockerfile -t motchie8/dotfiles:ubuntu
FROM ubuntu:20.04

ARG user=ubuntu
ARG sudogroup=sudo

RUN useradd $user -m && gpasswd -a $user $sudogroup

RUN mkdir -p /etc/sudoers.d && echo "$user ALL=(ALL:ALL) NOPASSWD: ALL" | tee /etc/sudoers.d/$user

RUN apt update -y && apt install -y sudo

USER $user

COPY . /home/$user/.dotfiles

RUN sudo chown -R $user /home/$user/.dotfiles

WORKDIR /home/$user/.dotfiles

RUN ./bin/install.sh --tmux-prefix-key b
# RUN nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'
