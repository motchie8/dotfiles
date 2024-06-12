#!/bin/bash
set -eu

cat /dev/null <<EOF
------------------------------------------------------------------------
Source common functions and variables.
------------------------------------------------------------------------
EOF
source "$(dirname $(realpath $0))/common.sh"

cat /dev/null <<EOF
------------------------------------------------------------------------
Check necessary environment variables and libs
------------------------------------------------------------------------
EOF

if [ "$OS" != $UBUNTU ]; then
    err_echo "Currently, this script is only supported on Ubuntu"
    exit_with_unsupported_os
fi

GOOGLE_DRIVE_OCAMLFUSE_CLIENT_ID="${GOOGLE_DRIVE_OCAMLFUSE_CLIENT_ID:-}"
GOOGLE_DRIVE_OCAMLFUSE_CLIENT_SECRET="${GOOGLE_DRIVE_OCAMLFUSE_CLIENT_SECRET:-}"

if [[ -z "${GOOGLE_DRIVE_OCAMLFUSE_CLIENT_ID}" ]]; then
    err_echo "GOOGLE_DRIVE_OCAMLFUSE_CLIENT_ID is not set in environment variables."
    exit 1
fi
if [[ -z "${GOOGLE_DRIVE_OCAMLFUSE_CLIENT_SECRET}" ]]; then
    err_echo "GOOGLE_DRIVE_OCAMLFUSE_CLIENT_SECRET is not set in environment variables."
    exit 1
fi

cat /dev/null <<EOF
------------------------------------------------------------------------
Main functions.
------------------------------------------------------------------------
EOF

# Install google-drive-ocamlfuse
sudo apt install software-properties-common -y
# for stable version
sudo add-apt-repository ppa:alessandro-strada/ppa
# for beta version
# sudo add-apt-repository ppa:alessandro-strada/google-drive-ocamlfuse-beta
sudo apt update
sudo apt upgrade -y
sudo apt install google-drive-ocamlfuse -y

# Create a browser fake file
sudo sh -c 'cat >| /bin/firefox <<EOF
#!/bin/sh
echo \$* > /dev/stderr
EOF'
sudo chmod 777 /bin/firefox

# Setup FUSE settings
sudo touch /etc/fuse.conf
sudo sed -i '/# *user_allow_other/c\user_allow_other' /etc/fuse.conf || echo 'user_allow_other' | sudo tee -a /etc/fuse.conf

# Setup mount point
sudo mkdir -p /mnt/google_drive
sudo chmod 777 /mnt/google_drive

# Mount Google Drive for the first time
info_echo "Please copy the URL that is output below, paste it into your browser, and follow the steps to authorize access to Google Drive."
sudo google-drive-ocamlfuse -id $GOOGLE_DRIVE_OCAMLFUSE_CLIENT_ID -secret $GOOGLE_DRIVE_OCAMLFUSE_CLIENT_SECRET -label google_drive /mnt/google_drive -o allow_other -browser firefox

# Mount Google Drive on startup
# Create gdfuse command
sudo sh -c 'cat >| /usr/bin/gdfuse <<EOF
#!/bin/bash
/usr/bin/google-drive-ocamlfuse -label \$1 \$*
exit 0
EOF'
sudo chmod 755 /usr/bin/gdfuse

# Setup /etc/fstab
if ! grep -q "gdfuse#google_drive" /etc/fstab; then
    echo "gdfuse#google_drive /mnt/google_drive fuse uid=0,gid=0,allow_other,user,_netdev 0 0" | sudo tee -a /etc/fstab
fi

# Unmount and remount
sudo fusermount -u /mnt/google_drive
sudo mount -a

# Setup Symbolic Link for task.md
if [ ! -e $HOME/vimwiki/todo ]; then
    mkdir -p $HOME/vimwiki/todo
fi
if [ ! -e $HOME/vimwiki/todo/task.md ]; then
    ln -s /mnt/google_drive/vimwiki/data/todo/task.md $HOME/vimwiki/todo/task.md
fi
