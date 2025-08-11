#!/usr/bin/env bash
set -eu

cat /dev/null <<EOF
------------------------------------------------------------------------
Source common functions and variables.
------------------------------------------------------------------------
EOF
source "bin/common.sh"

cat /dev/null <<EOF
------------------------------------------------------------------------
Parse arguments.
------------------------------------------------------------------------
EOF

TMUX_PREFIX_KEY=""
BUILD_NEOVIM=false

show_help() {
    echo "Usage: ./bin/install_dev_env_libs.sh -t {TMUX_PREFIX_KEY} [-b]"
    echo "  -t [TMUX_PREFIX_KEY]  Specify prefix Key for tmux. ex. \"-t b\""
    echo "  -b                    Build Neovim from source"
    echo "  -h                    Show this help message and exit"
}

while getopts ":t:hb" option; do
    case "${option}" in
        t) TMUX_PREFIX_KEY="${OPTARG}" ;;
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

if [[ -z "${TMUX_PREFIX_KEY}" ]]; then
    show_help
    exit 1
fi

cat /dev/null <<EOF
------------------------------------------------------------------------
Functions for installation.
------------------------------------------------------------------------
EOF

build_neovim() {
    info_echo "**** Build Neovim from source****"
    # install prerequisites
    if [ "$OS" = "$UBUNTU" ]; then
        sudo apt-get install -y ninja-build gettext unzip curl luarocks
    elif [ "$OS" = "$MAC_OS" ]; then
        set +e
        brew install ninja gettext curl luarocks
        set -e
    else
        exit_with_unsupported_os
    fi
    # build Neovim
    if [ ! -e "$BUILD_DIR/neovim" ]; then
        git clone --depth 1 https://github.com/neovim/neovim "$BUILD_DIR/neovim"
        cd "$BUILD_DIR/neovim"
        make CMAKE_BUILD_TYPE=RelWithDebInfo
        sudo PATH="$PATH" make install
    else
        cd "$BUILD_DIR/neovim"
        if ! git pull | grep -q "Already up to date"; then
            make distclean
            make CMAKE_BUILD_TYPE=RelWithDebInfo
            sudo PATH="$PATH" make install
        fi
    fi
    cd "$DOTFILES_DIR"
}

install_neovim() {
    # cf. https://github.com/neovim/neovim/wiki/Installing-Neovim
    info_echo "**** Install or update Neovim ****"
    if [ "$OS" = "$UBUNTU" ]; then
        if [ "$BUILD_NEOVIM" = true ] || [ "$ARCH" == "arm64" ] || [ "$ARCH" == "aarch64" ]; then
            build_neovim
        else
            sudo apt-get install -y software-properties-common
            sudo add-apt-repository -y ppa:neovim-ppa/unstable
            sudo apt-get update -y
            sudo apt-get install -y neovim
        fi
    elif [ "$OS" = "$MAC_OS" ]; then
        if [ "$BUILD_NEOVIM" = true ]; then
            build_neovim
        else
            set +e
            brew unlink luajit
            brew unlink neovim
            brew install --HEAD luajit
            brew install --HEAD neovim
            brew link luajit
            brew link neovim
            set -e
        fi
    else
        exit_with_unsupported_os
    fi
}

install_anyenv_and_env_libs() {
    info_echo "**** Setup env libs ****"
    if ! type anyenv >/dev/null 2>&1; then
        info_echo "**** Install anyenv ****"
        git clone --depth 1 https://github.com/anyenv/anyenv "$HOME"/.anyenv
        export PATH="$HOME/.anyenv/bin:$PATH"
        eval "$(anyenv init -)"
        anyenv install --force-init
    fi
    if ! type tfenv >/dev/null 2>&1; then
        info_echo "**** Install tfenv ****"
        anyenv install tfenv
        eval "$(anyenv init -)"
        tfenv install latest
    fi
    if [ ! -e "$(anyenv root)"/plugins/anyenv-update ]; then
        info_echo "**** Install anyenv-update ****"
        mkdir -p $(anyenv root)/plugins
        git clone https://github.com/znz/anyenv-update.git $(anyenv root)/plugins/anyenv-update
    fi
}

set_zsh_as_default_shell() {
    DEFAULT_SHELL=$(echo "$SHELL" | awk -F '[/]' '{print $NF}')
    if [ "$DEFAULT_SHELL" != "zsh" ]; then
        info_echo "**** Change default shell from ${DEFAULT_SHELL} to zsh ****"
        if ! grep -q "zsh" /etc/shells; then
            which zsh >>/etc/shells
        fi
        sudo chsh -s "$(which zsh)" "$(whoami)"
    fi
}

setup_zsh() {
    # install zplug
    export ZPLUG_HOME="$BUILD_DIR/zplug"
    if [ ! -e "$ZPLUG_HOME" ]; then
        info_echo "**** Install zplug ****"
        git clone --depth 1 https://github.com/zplug/zplug "$ZPLUG_HOME"
    else
        info_echo "**** Update zplug ****"
        pushd "$ZPLUG_HOME"
        git pull
        popd
    fi
    # install zprezto and setup zsh dotfiles
    if [ ! -e "$BUILD_DIR/zprezto" ]; then
        info_echo "**** Install zprezto ****"
        git clone --depth 1 --recursive https://github.com/sorin-ionescu/prezto.git "$BUILD_DIR/zprezto"
        for rcfile_name in zlogin zlogout zpreztorc zprofile zshenv; do
            ln -s "$BUILD_DIR/zprezto/runcoms/.$rcfile_name" "$HOME/.$rcfile_name"
        done
    else
        info_echo "**** Update zprezto ****"
        pushd "$BUILD_DIR/zprezto"
        if ! git pull | grep -q "Already up to date"; then
            for rcfile_name in zlogin zlogout zpreztorc zprofile zshenv; do
                unlink "$HOME/.$rcfile_name"
                ln -s "$BUILD_DIR/zprezto/runcoms/.$rcfile_name" "$HOME/.$rcfile_name"
            done
        fi
        popd
    fi
    set_zsh_as_default_shell
}

install_iceberg_tmux_conf() {
    # download iceberg.tmux.conf
    if [ ! -e "$BUILD_DIR/tmux/colors/iceberg.tmux.conf" ]; then
        info_echo "**** Install tmux color schema ****"
        mkdir -p "$BUILD_DIR/tmux/colors/"
        wget -O "$BUILD_DIR/tmux/colors/iceberg.tmux.conf" https://raw.githubusercontent.com/gkeep/iceberg-dark/master/.tmux/iceberg.tmux.conf
    fi
}

create_tmux_user_conf() {
    # create .tmux.user.conf for custom prefix key
    info_echo "**** Create or update .tmux.user.conf to set prefix key****"
    cat <<EOL >"$DOTFILES_DIR"/tmux/tmux.user.conf
unbind C-b
set-option -g prefix C-${TMUX_PREFIX_KEY}
bind-key C-${TMUX_PREFIX_KEY} send-prefix
EOL
}

install_tmux_mem_cpu_load() {
    # install tmux-mem-cpu-load
    if [ ! -e "$DOTFILES_DIR"/tmux/plugins/tmux-mem-cpu-load ]; then
        info_echo "**** Install tmux-mem-cpu-load ****"
        mkdir -p "$DOTFILES_DIR"/tmux/plugins
        git clone --depth 1 https://github.com/thewtex/tmux-mem-cpu-load.git "$DOTFILES_DIR"/tmux/plugins/tmux-mem-cpu-load
        pushd "$DOTFILES_DIR"/tmux/plugins/tmux-mem-cpu-load
        cmake .
        make
        sudo make install
        popd
    else
        pushd "$DOTFILES_DIR"/tmux/plugins/tmux-mem-cpu-load
        if ! git pull | grep -q "Already up to date"; then
            info_echo "**** Update tmux-mem-cpu-load ****"
            cmake .
            make
            sudo make install
        fi
        popd
    fi
}

install_act() {
    if ! type act >/dev/null 2>&1; then
        info_echo "**** Install act ***"
        if [ "$OS" = "$UBUNTU" ]; then
            if [ "$ARCH" == "arm64" ] || [ "$ARCH" == "aarch64" ]; then
                wget -O act.tar.gz https://github.com/nektos/act/releases/latest/download/act_Linux_arm64.tar.gz
            elif [ "$ARCH" == "x86_64" ]; then
                wget -O act.tar.gz https://github.com/nektos/act/releases/latest/download/act_Linux_x86_64.tar.gz
            else
                echo "Unsupported architecture: $ARCH"
                exit 1
            fi
            sudo tar xf act.tar.gz -C /usr/local/bin act
            rm act.tar.gz
        elif [ "$OS" = "$MAC_OS" ]; then
            brew install act
        else
            exit_with_unsupported_os
        fi
    fi
}

install_formatter() {
    # install sh formatter
    if ! type shfmt >/dev/null 2>&1; then
        info_echo "**** Install shfmt for sh formatter ****"
        if [ "$OS" = "$UBUNTU" ]; then
            export GO111MODULE=on
            go install mvdan.cc/sh/v3/cmd/shfmt@latest
        elif [ "$OS" = "$MAC_OS" ]; then
            brew install shfmt
        else
            exit_with_unsupported_os
        fi
    fi

    # install rust formatter
    if ! type stylua >/dev/null 2>&1; then
        info_echo "**** Install stylua for rust formatter ***"
        cargo install stylua
    fi
    # install toml formatter
    #if ! type taplo >/dev/null 2>&1; then
    #    export OPENSSL_DIR=/usr/include/openssl
    #    cargo install taplo-cli
    #fi

    # install sql formatter
    if ! type sqlfmt >/dev/null 2>&1; then
        info_echo "**** Install sqlfmt ****"
        uv tool install 'shandy-sqlfmt[jinjafmt]'
    fi

    # install formatter for various filetypes
    if ! type prettier >/dev/null 2>&1; then
        info_echo "**** Install prettier for formatter for various filetypes ***"
        npm -g install prettier
    fi
}

install_linter() {
    if ! type sqlfluff >/dev/null 2>&1; then
        info_echo "**** Install sqlfluff ****"
        uv tool install sqlfluff --with sqlfluff-templater-dbt
    fi
}

install_fzf() {
    if [ ! -e "$DOTFILES_DIR"/.fzf ]; then
        info_echo "**** Install fzf ***"
        git clone --depth 1 https://github.com/junegunn/fzf.git "$DOTFILES_DIR"/.fzf
        "$DOTFILES_DIR"/.fzf/install --key-bindings --completion --no-update-rc
    else
        pushd "$DOTFILES_DIR"/.fzf
        if ! git pull | grep -q "Already up to date"; then
            info_echo "**** Update fzf ***"
            "$DOTFILES_DIR"/.fzf/install --key-bindings --completion --no-update-rc
        fi
        popd
    fi
}

install_terraform_libs() {
    if ! type terraform-docs >/dev/null 2>&1; then
        info_echo "**** Install terraform-docs ***"
        if [ "$OS" = "$UBUNTU" ]; then
            TERRAFORM_DOCS_VERSION="v0.17.0"
            go install github.com/terraform-docs/terraform-docs@"${TERRAFORM_DOCS_VERSION}"
            export PATH=$PATH:$HOME/go/bin
        elif [ "$OS" = "$MAC_OS" ]; then
            brew install terraform-docs
        else
            exit_with_unsupported_os
        fi
        # Setup code completion for zsh
        ZSH_COMPLETION_DIR="/usr/local/share/zsh/site-functions"
        TERRAFORM_DOCS_CODE_COMPLETION_PATH="${ZSH_COMPLETION_DIR}/_terraform-docs"
        if [ ! -e "$TERRAFORM_DOCS_CODE_COMPLETION_PATH" ]; then
            sudo mkdir -p "$ZSH_COMPLETION_DIR"
            terraform-docs completion zsh | sudo tee "$TERRAFORM_DOCS_CODE_COMPLETION_PATH" >/dev/null
        fi
    fi
    if ! type terraform-ls >/dev/null 2>&1; then
        info_echo "**** Install terraform-ls ***"
        if [ "$OS" = "$UBUNTU" ]; then
            wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
            sudo apt-get install -y lsb-release
            echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
            sudo apt update
            sudo apt install terraform-ls
        elif [ "$OS" = "$MAC_OS" ]; then
            brew install hashicorp/tap/terraform-ls
        else
            exit_with_unsupported_os
        fi
    fi
}

install_nerd_fonts() {
    info_echo "**** Install nerd fonts ****"
    if [ "$OS" = "$MAC_OS" ]; then
        brew install --cask font-roboto-mono-nerd-font
    fi
    # NOTE: install RobotMono Nerd Font for WSL manually
    # cf. Option 1: Download already patched font
    # https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts/RobotoMono
}

install_gcloud_cli() {
    if ! type gcloud >/dev/null 2>&1; then
        info_echo "**** Install gcloud cli ****"
        if [ "$OS" = "$MAC_OS" ]; then
            brew install --cask google-cloud-sdk
        elif [ "$OS" = "$UBUNTU" ]; then
            if [ "$ARCH" == "arm64" ] || [ "$ARCH" == "aarch64" ]; then
                # NOTE: currently, gcloud CLI is not available for arm64 ubuntu
                # > 以下のパッケージには満たせない依存関係があります: google-cloud-cli : 依存: python3 (< 3.12) しかし、3.12.3-0ubuntu2 はインストールされようとしています: 問題を解決することができません。壊れた変更禁止パッケージがあります。
                info_echo "Currently, gcloud CLI is not available for arm64 Linux. So skip installation."
            else
                sudo apt-get install -y apt-transport-https ca-certificates gnupg curl sudo
                echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
                curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
                sudo apt-get update && sudo apt-get install -y google-cloud-cli
            fi
            # NOTE: init gcloud CLI by running `gcloud init`
        else
            exit_with_unsupported_os
        fi
    fi
}

install_aws_cli() {
    if ! type aws >/dev/null 2>&1; then
        info_echo "**** Install aws cli ****"
        if [ "$OS" = "$MAC_OS" ]; then
            brew install awscli
        elif [ "$OS" = "$UBUNTU" ]; then
            curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
            unzip awscliv2.zip
            sudo ./aws/install
            rm awscliv2.zip
            rm -rf aws
        fi
    fi
}

install_heml() {
    if ! type helm >/dev/null 2>&1; then
        info_echo "**** Install Helm ****"
        if [ "$OS" = "$MAC_OS" ]; then
            brew install helm
        elif [ "$OS" = "$UBUNTU" ]; then
            curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg >/dev/null
            sudo apt-get install apt-transport-https --yes
            echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
            sudo apt-get update -y
            sudo apt-get install -y helm
        else
            exit_with_unsupported_os
        fi
    fi
}

install_snowsql() {
    if ! type snowsql >/dev/null 2>&1; then
        info_echo "**** Install SnowSQL ****"
        if [ "$OS" = "$MAC_OS" ]; then
            if [ "$ARCH" == "x86_64" ]; then
                brew install --cask snowflake-snowsql
            else
                err_echo "Currently, for MacOS with arm64, SnowSQL needs to be installed using pkg."
                err_echo "cf. https://developers.snowflake.com/snowsql/"
            fi
        elif [ "$OS" = "$UBUNTU" ]; then
            if [ "$ARCH" == "x86_64" ]; then
                mkdir -p "$BUILD_DIR/snowsql/bin"
                cd "$BUILD_DIR/snowsql"
                VERSION=1.2.28
                BOOTSTRAP_VERSION=1.2
                curl -O https://sfc-repo.snowflakecomputing.com/snowsql/bootstrap/"${BOOTSTRAP_VERSION}"/linux_x86_64/snowsql-${VERSION}-linux_x86_64.bash
                touch "$DOTFILES_DIR"/.zshrc.tmp
                SNOWSQL_DEST="$HOME"/bin SNOWSQL_LOGIN_SHELL="$DOTFILES_DIR"/.zshrc.tmp bash snowsql-${VERSION}-linux_x86_64.bash
                rm -rf "$DOTFILES_DIR"/.zshrc.tmp
            else
                err_echo "Currently, SnowSQL is not supported on arm64 Linux."
            fi
        else
            exit_with_unsupported_os
        fi
    fi
}

install_devcontainer_cli() {
    if ! type devcontainer >/dev/null 2>&1; then
        info_echo "**** Install devcontainer cli ****"
        npm install -g @devcontainers/cli
    fi
    if [ ! -e "$DOTFILES_DIR"/devcontainer/devcontainer-cli-port-forwarder ]; then
        info_echo "**** Install devcontainer cli port forwarder ****"
        mkdir -p "$DOTFILES_DIR"/devcontainer
        git clone --depth 1 https://github.com/nohzafk/devcontainer-cli-port-forwarder.git "$DOTFILES_DIR"/devcontainer/devcontainer-cli-port-forwarder
    fi
}

install_lua_language_server() {
    if ! type lua-language-server >/dev/null 2>&1; then
        info_echo "**** Install lua-language-server ****"
        if [ "$OS" = "$MAC_OS" ]; then
            brew install lua-language-server
        elif [ "$OS" = "$UBUNTU" ]; then
            mkdir -p "$BUILD_DIR/lua-language-server"
            cd "$BUILD_DIR/lua-language-server"
            LUA_LANGUAGE_SERVER_VERSION=3.9.1
            if [ "$ARCH" == "arm64" ] || [ "$ARCH" == "aarch64" ]; then
                LUA_LANGUAGE_SERVER_ARCH="arm64"
            else
                LUA_LANGUAGE_SERVER_ARCH="x64"
            fi
            wget https://github.com/LuaLS/lua-language-server/releases/download/"${LUA_LANGUAGE_SERVER_VERSION}"/lua-language-server-${LUA_LANGUAGE_SERVER_VERSION}-linux-${LUA_LANGUAGE_SERVER_ARCH}.tar.gz
            tar zxvf lua-language-server-${LUA_LANGUAGE_SERVER_VERSION}-linux-${LUA_LANGUAGE_SERVER_ARCH}.tar.gz
            ln -s "$(readlink -f bin/lua-language-server)" "$HOME"/bin/lua-language-server
            cd "$DOTFILES_DIR"
        fi
    fi
}

install_shellcheck() {
    if ! type shellcheck >/dev/null 2>&1; then
        info_echo "**** Install shellcheck ****"
        if [ "$OS" = "$MAC_OS" ]; then
            brew install shellcheck
        elif [ "$OS" = "$UBUNTU" ]; then
            sudo apt install -y shellcheck
        else
            exit_with_unsupported_os
        fi
    fi
}

install_vhs() {
    if ! type vhs >/dev/null 2>&1; then
        info_echo "**** Install vhs ****"
        if [ "$OS" = "$MAC_OS" ]; then
            brew install vhs ttyd ffmpeg
        elif [ "$OS" = "$UBUNTU" ]; then
            # install vhs
            go install github.com/charmbracelet/vhs@latest
            # install dependencies for vhs
            sudo apt install ffmpeg -y
            if [ "$ARCH" == "arm64" ] || [ "$ARCH" == "aarch64" ]; then
                suffix="aarch64"
            else
                suffix="x86_64"
            fi
            version="1.7.7"
            wget https://github.com/tsl0922/ttyd/releases/download/${version}/ttyd.${suffix} -O "$HOME"/bin/ttyd
            chmod +x "$HOME"/bin/ttyd
        else
            exit_with_unsupported_os
        fi
    fi
}

install_aider() {
    if ! type aider >/dev/null 2>&1; then
        info_echo "**** Install Aider ****"
        # TMP: install aider from source for MCP support
        # uv tool install --force --python python3.12 --with pip aider-chat@latest
        # uv tool install --force --reinstall --python python3.12 --with pip --with google-cloud-aiplatform --with httpx --with playwright "git+https://github.com/quinlanjager/aider.git@feature/litellm-mcp"
        uv tool install --force --reinstall --python python3.12 --with pip --with google-cloud-aiplatform --with httpx --with playwright "git+https://github.com/arosov/aider.git@mcp"
        # TMP: create a mcp profile from example config
        if [ ! -e "$DOTFILES_DIR"/config/aider/aider.mcp.profiles.yml ]; then
            info_echo "**** Create aider.mcp.profiles.yml using example config ****"
            cp "$DOTFILES_DIR"/config/aider/aider.mcp.profiles.example.yml "$DOTFILES_DIR"/config/aider/aider.mcp.profiles.yml
        fi
        # TMP: create a symlink to the mcp profile
        if [ ! -e "$HOME"/.aider.mcp.profiles.yml ]; then
            info_echo "**** Create symlink to mcp profile ****"
            ln -s "$DOTFILES_DIR"/config/aider/aider.mcp.profiles.yml "$HOME"/.aider.mcp.profiles.yml
        fi
        # Init aider configs
        cd "$DOTFILES_DIR"
        if [ ! -e "$DOTFILES_DIR"/config/aider/aider.conf.yml ]; then
            info_echo "**** Create aider.conf.yml using example config ****"
            cp "$DOTFILES_DIR"/config/aider/aider.conf.example.yml "$DOTFILES_DIR"/config/aider/aider.conf.yml
        fi
        if [ ! -e "$DOTFILES_DIR"/config/mcp/mcp.json ]; then
            info_echo "**** Create mcp.json using example config ****"
            cp "$DOTFILES_DIR"/config/mcp/mcp.example.json "$DOTFILES_DIR"/config/mcp/mcp.json
        fi
        info_echo "**** Install PortAudio for voice coding support ****"
        if [ "$OS" = "$MAC_OS" ]; then
            brew install portaudio
        elif [ "$OS" = "$UBUNTU" ]; then
            sudo apt-get install libportaudio2 -y
            sudo apt install libasound2-plugins -y
        else
            exit_with_unsupported_os
        fi
    fi
}

install_imagemagick() {
    if ! type convert >/dev/null 2>&1; then
        info_echo "**** Install ImageMagick ****"
        if [ "$OS" = "$MAC_OS" ]; then
            brew install imagemagick
        elif [ "$OS" = "$UBUNTU" ]; then
            sudo apt install -y imagemagick
        else
            exit_with_unsupported_os
        fi
    fi
}

install_gemini_cli() {
    if ! type gemini >/dev/null 2>&1; then
        info_echo "**** Install Gemini CLI ****"
        npm install -g @google/gemini-cli
    fi
    if [ ! -e "$DOTFILES_DIR"/config/gemini-cli/settings.json ]; then
        info_echo "**** Create Gemini CLI config file using example config ****"
        cp "$DOTFILES_DIR"/config/gemini-cli/settings.example.json "$DOTFILES_DIR"/config/gemini-cli/settings.json
    fi
}

install_github_cli() {
    if ! type gh >/dev/null 2>&1; then
        info_echo "**** Install GitHub CLI ****"
        if [ "$OS" = "$MAC_OS" ]; then
            brew install gh
        elif [ "$OS" = "$UBUNTU" ]; then
            sudo apt install -y gh
        else
            exit_with_unsupported_os
        fi
    fi
}

install_cursor_cli() {
    # install Cursor CLI only on MacOS
    if [ "$OS" = "$MAC_OS" ]; then
        if ! type cursor-agent >/dev/null 2>&1; then
            info_echo "**** Install Cursor CLI ****"
            curl https://cursor.com/install -fsS | bash
        fi
        if [ ! -e "$DOTFILES_DIR"/config/cursor/mcp.json ]; then
            info_echo "**** Create Cursor MCP config file using example config ****"
            cp "$DOTFILES_DIR"/config/cursor/mcp.example.json "$DOTFILES_DIR"/config/cursor/mcp.json
            mkdir -p "$HOME"/.cursor
        fi
    fi
}

cat /dev/null <<EOF
------------------------------------------------------------------------
Installation steps
------------------------------------------------------------------------
EOF

install_neovim

install_anyenv_and_env_libs

setup_zsh

install_iceberg_tmux_conf

install_act

install_formatter

install_linter

install_fzf

install_tmux_mem_cpu_load

create_tmux_user_conf

install_nerd_fonts

install_gcloud_cli

install_aws_cli

install_heml

install_terraform_libs

install_snowsql

install_devcontainer_cli

install_lua_language_server

install_shellcheck

install_vhs

install_aider

install_imagemagick

install_gemini_cli

install_github_cli

install_cursor_cli

info_echo "**** Installation succeeded ****"
