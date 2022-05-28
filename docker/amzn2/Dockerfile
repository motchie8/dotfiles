# docker build . -f docker/amzn2/Dockerfile -t motchie8/dotfiles:amzn2
FROM amazonlinux:2

ARG user=ec2-user
ARG sudogroup=wheel

RUN yum update -y && yum install -y sudo util-linux shadow-utils yum-utils

RUN useradd $user -m -U && usermod -G $sudogroup $user

RUN mkdir -p /etc/sudoers.d && echo "$user ALL=(ALL:ALL) NOPASSWD: ALL" | tee /etc/sudoers.d/$user

USER $user

COPY . /home/$user/.dotfiles

RUN sudo chown -R $user /home/$user/.dotfiles

WORKDIR /home/$user/.dotfiles

RUN ./bin/install.sh --target local
RUN nvim --headless -c 'call dein#update()' -c 'CocUpdate' -c 'quitall'
