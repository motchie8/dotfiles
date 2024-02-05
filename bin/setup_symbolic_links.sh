#!/bin/bash
set -eu

DOTFILES_DIR=$(dirname $(dirname $(realpath $0)))

info_echo() {
    echo -e "\033[32m$1\033[0m"
}

setup_symbolic_links() {
    info_echo "**** Setup symbolic links ****"
    target_paths=("$HOME/.zshrc" "$HOME/.config/nvim" "$HOME/.config/nvim/coc-settings.json" "$HOME/.config/nvim/init.lua" "$HOME/.config/nvim/cheatsheet.txt" "$HOME/.tmux.conf")
    link_paths=("$DOTFILES_DIR/.zshrc" "$DOTFILES_DIR/.vim" "$DOTFILES_DIR/coc-settings.json" "$DOTFILES_DIR/init.lua" "$DOTFILES_DIR/cheatsheet.txt" "$DOTFILES_DIR/tmux/tmux.common.conf")
    mkdir -p ~/.config
    for i in "${!target_paths[@]}"; do
        if [ -e "${target_paths[i]}" ]; then
            if [ ! -L "${target_paths[i]}" ]; then
                info_echo "File already exists at ${target_paths[i]}, so skip creating symbolic link"
                continue
            else
                unlink "${target_paths[i]}"
            fi
        fi
        ln -s "${link_paths[i]}" "${target_paths[i]}"
    done
}

setup_symbolic_links
