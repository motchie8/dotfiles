#!/bin/bash
set -eu

DOTFILES_DIR=$(dirname $(dirname $(realpath $0)))

info_echo() {
    echo -e "\033[32m$1\033[0m"
}

err_echo() {
    echo -e "\033[31m$1\033[0m"
}

cat /dev/null <<EOF
------------------------------------------------------------------------
Parse arguments.
------------------------------------------------------------------------
EOF

TASK_SERVER_USER_NAME=""
TASK_SERVER_HOST_NAME=""
TASK_SERVER_PORT=""
TASK_SERVER_CREDENTIAL=""

show_help() {
    echo "Usage: ./bin/setup_task_server.sh -u USER_NAME -n HOST_NAME -p PORT -c CREDENTIAL"
    echo "  -h                          Show this help message and exit"
    echo "  -u USER_NAME    Specify user name for task server. ex. \"-u motchie8\""
    echo "  -n HOST_NAME    Specify host name for task server. ex. \"-n 0.0.0.0\""
    echo "  -p PORT         Specify port for task server. ex. \"-p 12345\""
    echo "  -c CREDENTIAL   Specify credential for task server. ex. \"-c motchie8/client/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxx\""
}

while getopts ":unp:h" option; do
    case "${option}" in
        t) TASK_SERVER_USER_NAME="${OPTARG}" ;;
        n) TASK_SERVER_HOST_NAME="${OPTARG}" ;;
        p) TASK_SERVER_PORT="${OPTARG}" ;;
        c) TASK_SERVER_CREDENTIAL="${OPTARG}" ;;
        b) BUILD_NEOVIM=true ;;
        h)
            show_help
            exit 0
            ;;
        *)
            show_help
            exit 1
            ;;
    esac
done

cat /dev/null <<EOF
------------------------------------------------------------------------
Check necessary arguments, files and libs
------------------------------------------------------------------------
EOF

# check if necessary arguments are set
if [ -z "$TASK_SERVER_USER_NAME" ] || [ -z "$TASK_SERVER_HOST_NAME" ] || [ -z "$TASK_SERVER_PORT" ] || [ -z "$TASK_SERVER_CREDENTIAL" ]; then
    show_help
    exit 1
fi

if [ ! -e "$HOME/.task/${TASK_SERVER_USER_NAME}.cert.pem" ]; then
    err_echo "Certificate file for ${TASK_SERVER_USER_NAME} does not exist at $HOME/.task/${TASK_SERVER_USER_NAME}.cert.pem"
    exit 1
fi
if [ ! -e "$HOME/.task/${TASK_SERVER_USER_NAME}.key.pem" ]; then
    err_echo "Key file for ${TASK_SERVER_USER_NAME} does not exist at $HOME/.task/${TASK_SERVER_USER_NAME}.key.pem"
    exit 1
fi
if [ ! -e "$HOME/.task/ca.cert.pem" ]; then
    err_echo "CA file does not exist at $HOME/.task/ca.cert.pem"
    exit 1
fi

if ! type task >/dev/null 2>&1; then
    err_echo "Taskwarrior client is not installed"
    exit 1
fi

cat /dev/null <<EOF
------------------------------------------------------------------------
Setup Taskwarrior client
------------------------------------------------------------------------
EOF

info_echo "**** Setup Taskwarrior client to connect to Task Server ****"

task config taskd.certificate -- $HOME/.task/${TASK_SERVER_USER_NAME}.cert.pem
task config taskd.key -- $HOME/.task/${TASK_SERVER_USER_NAME}.key.pem
task config taskd.ca -- $HOME/.task/ca.cert.pem
task config taskd.server -- $TASK_SERVER_HOST_NAME:$TASK_SERVER_PORT
task config taskd.credentials -- $TASK_SERVER_CREDENTIAL

# start sync for the first time
task sync init

# start sync after the first time sync
task sync
