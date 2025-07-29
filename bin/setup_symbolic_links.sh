#!/usr/bin/env bash
set -eu

cat /dev/null <<EOF
------------------------------------------------------------------------
Source common functions and variables.
------------------------------------------------------------------------
EOF
# source "$(dirname "$(realpath $0)")/common.sh"
source "bin/common.sh"

cat /dev/null <<EOF
------------------------------------------------------------------------
Parse arguments.
------------------------------------------------------------------------
EOF

DELETE_LINKS=false

show_help() {
    echo "Usage: ./bin/setup_symbolic_links.sh [-d]"
    echo "  -d                    Delete existing symbolic links"
    echo "  -h                    Show this help message and exit"
}

while getopts "::dh" option; do
    case "${option}" in
        d) DELETE_LINKS=true ;;
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
Main functions.
------------------------------------------------------------------------
EOF

target_paths=("$HOME/.zshrc" "$HOME/.config/nvim/coc-settings.json" "$HOME/.config/nvim/init.lua" "$HOME/.config/nvim/cheatsheet.txt" "$HOME/.tmux.conf" "$HOME/.config/nvim/lua" "$HOME/.aider.conf.yml" "$HOME/mcp.json" "$HOME/.cursor/mcp.json")
link_paths=("$DOTFILES_DIR/.zshrc" "$DOTFILES_DIR/coc-settings.json" "$DOTFILES_DIR/init.lua" "$DOTFILES_DIR/cheatsheet.txt" "$DOTFILES_DIR/tmux/tmux.common.conf" "$DOTFILES_DIR/lua" "$DOTFILES_DIR/config/aider/aider.conf.yml" "$DOTFILES_DIR/config/mcp/mcp.json" "$DOTFILES_DIR/config/mcp/mcp.json")

setup_symbolic_links() {
    info_echo "**** Setup symbolic links ****"
    mkdir -p ~/.config/nvim
    mkdir -p ~/.cursor
    for i in "${!target_paths[@]}"; do
        if [ ! -L "${target_paths[i]}" ]; then
            if [ -e "${target_paths[i]}" ]; then
                err_echo "${target_paths[i]} already exists."
                exit 1
            else
                ln -s "${link_paths[i]}" "${target_paths[i]}"
            fi
        fi
    done
}

delete_symbolic_links() {
    info_echo "**** Delete symbolic links ****"
    for i in "${!target_paths[@]}"; do
        if [ -L "${target_paths[i]}" ]; then
            unlink "${target_paths[i]}"
        fi
    done
}

setup_dir() {
    if [ ! -e "$HOME/vimwiki/todo" ]; then
        info_echo "**** Create directory for vimwiki for task management****"
        mkdir -p "$HOME/vimwiki/todo"
    fi
    if [ ! -e "$HOME/vimwiki/aichat" ]; then
        info_echo "**** Create directory for vim-ai****"
        mkdir -p "$HOME/vimwiki/aichat"
    fi
}

if [ "$DELETE_LINKS" = true ]; then
    delete_symbolic_links
else
    setup_symbolic_links
    setup_dir
fi
