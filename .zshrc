# -----------------------------
# DOTFILES_DIR
# -----------------------------
DOTFILES_DIR=$(dirname $(realpath $HOME/.zshrc))

# -----------------------------
# PATH
# -----------------------------
export PATH="$HOME/bin:$PATH"

# homebrew
if [ -e /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# rust
export PATH="$HOME/.cargo/bin:$PATH"

# go
export PATH=$PATH:/usr/local/go/bin
export PATH=$PATH:$HOME/go/bin

# anyenv
export PATH="$HOME/.anyenv/bin:$PATH"
eval "$(anyenv init -)"

# npm
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

# for uv
if [ -e $HOME/.local/bin ]; then
    export PATH="$HOME/.local/bin:$PATH"
fi

# -----------------------------
# Environment Variables
# -----------------------------

export LESS=' -R '
export LESSOPEN='| src-hilite-lesspipe.sh %s'

# -----------------------------
# Alias
# -----------------------------

alias ll='ls -l'
alias diff='diff -U1'
alias nf='nvim $(fzf)'
alias vim='nvim'
alias find_path='find_path() { command_name=$1; echo $PATH | tr ":" "\n" | while read -r dir; do if [[ -x "${dir}/${command_name}" ]]; then echo "${dir}/${command_name}"; fi; done; }; find_path'
alias drwm='docker_run_with_mount() { image_name=$1; docker run -it --rm -v $(pwd):/mnt/host -w /mnt/host ${image_name} bash; }; docker_run_with_mount'
alias docker_image_show_cmd='docker_image_show_cmd() { image_name=$1; docker inspect ${image_name} | jq -r ".[0].Config.Entrypoint, .[0].Config.Cmd"; }; docker_image_show_cmd'
alias dct='devcontainer up --workspace-folder . && devcontainer exec --workspace-folder . bash'
alias dcb='devcontainer build --workspace-folder . --no-cache'

# -----------------------------
# zsh settings
# -----------------------------

export ZPLUG_HOME=$DOTFILES_DIR/build/zplug
if [ -e $ZPLUG_HOME ]; then
    source $ZPLUG_HOME/init.zsh
    zplug "zsh-users/zsh-completions"
    zplug "zsh-users/zsh-autosuggestions"
    zplug "zsh-users/zsh-syntax-highlighting", defer:2
    zplug "b4b4r07/enhancd", use:init.sh
fi

source $DOTFILES_DIR/build/zprezto/init.zsh

# -----------------------------
# Completion
# -----------------------------

# 単語の入力途中でもTab補完を有効化
setopt complete_in_word

# 補完の選択を楽にする
zstyle ':completion:*' menu select

# 補完候補をできるだけ詰めて表示する
setopt list_packed

# 補完候補にファイルの種類も表示する
setopt list_types

# 色の設定
export LSCOLORS=Exfxcxdxbxegedabagacad

# 補完時の色設定
export LS_COLORS='di=01;34:ln=01;35:so=01;32:ex=01;31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'

# キャッシュの利用による補完の高速化
zstyle ':completion::complete:*' use-cache true

# 補完候補に色つける
autoload -U colors
colors
zstyle ':completion:*' list-colors "${LS_COLORS}"
#zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# 大文字・小文字を区別しない(大文字を入力した場合は区別する)
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# manの補完をセクション番号別に表示させる
zstyle ':completion:*:manuals' separate-sections true

# --prefix=/usr などの = 以降でも補完
setopt magic_equal_subst

# Bash互換モードの有効化
autoload bashcompinit && bashcompinit

autoload -Uz compinit && compinit
# AWS CLI
if [ -e /usr/local/bin/aws_completer ]; then
    complete -C '/usr/local/bin/aws_completer' aws
fi
# Terraform
if [ -e /usr/bin/terraform ]; then
    # terraform -install-autocomplete
    complete -o nospace -C /usr/bin/terraform terraform
fi

# uv
if type uv &>/dev/null; then
    eval "$(uv generate-shell-completion zsh)"
    eval "$(uvx --generate-shell-completion zsh)"
fi

# -----------------------------
# fzf
# -----------------------------

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
# fh - repeat history
fh() {
    print -z $( ([ -n "$ZSH_NAME" ] && fc -l 1 || history) | fzf +s --tac | sed -E 's/ *[0-9]*\*? *//' | sed -E 's/\\/\\\\/g')
}
# fbr - checkout git branch (including remote branches), sorted by most recent commit, limit 30 last branches
fbr() {
    local branches branch
    branches=$(git for-each-ref --count=30 --sort=-committerdate refs/heads/ --format="%(refname:short)") &&
        branch=$(echo "$branches" |
            fzf-tmux -d $((2 + $(wc -l <<<"$branches"))) +m) &&
        git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
}

# -----------------------------
# WSL
# -----------------------------
# setup DISPLAY for X11 clipboard sharing for WSL
if [ -e /mnt/wsl ]; then
    export DISPLAY=$(cat /etc/resolv.conf | grep nameserver | awk '{print $2}'):0
fi

# -----------------------------
# General
# -----------------------------

# set locale
export LANG="ja_JP.UTF-8"
export LC_ALL="ja_JP.UTF-8"
export LC_CTYPE="ja_JP.UTF-8"
export LANGUAGE="ja_JP:ja"

# CLIでコメントを有効化
setopt interactivecomments

# 色を使用
autoload -Uz colors
colors

# エディタをvimに設定
export EDITOR=vim

# Ctrl+Dでログアウトしてしまうことを防ぐ
#setopt IGNOREEOF

# cdした際のディレクトリをディレクトリスタックへ自動追加
setopt auto_pushd

# ディレクトリスタックへの追加の際に重複させない
setopt pushd_ignore_dups

# viキーバインド
bindkey -v

# フローコントロールを無効にする
setopt no_flow_control

# ワイルドカード展開を使用する
setopt extended_glob

# cdコマンドを省略して、ディレクトリ名のみの入力で移動
setopt auto_cd

# コマンドラインがどのように展開され実行されたかを表示するようになる
#setopt xtrace

# 自動でpushdを実行
setopt auto_pushd

# pushdから重複を削除
setopt pushd_ignore_dups

# ビープ音を鳴らさないようにする
setopt no_beep

# カッコの対応などを自動的に補完する
setopt auto_param_keys

# ディレクトリ名の入力のみで移動する
setopt auto_cd

# bgプロセスの状態変化を即時に知らせる
setopt notify

# 8bit文字を有効にする
setopt print_eight_bit

# 終了ステータスが0以外の場合にステータスを表示する
#setopt print_exit_value

# ファイル名の展開でディレクトリにマッチした場合 末尾に / を付加
setopt mark_dirs

# コマンドのスペルチェックをする
# setopt correct

# コマンドライン全てのスペルチェックをする
# setopt correct_all

# 上書きリダイレクトの禁止
setopt no_clobber

# sudo の後ろでコマンド名を補完する
zstyle ':completion:*:sudo:*' command-path /usr/local/sbin /usr/local/bin \
    /usr/sbin /usr/bin /sbin /bin /usr/X11R6/bin

# ps コマンドのプロセス名補完
zstyle ':completion:*:processes' command 'ps x -o pid,s,args'

# パスの最後のスラッシュを削除しない
setopt noautoremoveslash

# 各コマンドが実行されるときにパスをハッシュに入れる
#setopt hash_cmds

# rsysncでsshを使用する
export RSYNC_RSH=ssh

# その他
umask 022
ulimit -c 0

# -----------------------------
# Prompt
# -----------------------------
# %M    ホスト名
# %m    ホスト名
# %d    カレントディレクトリ(フルパス)
# %~    カレントディレクトリ(フルパス2)
# %C    カレントディレクトリ(相対パス)
# %c    カレントディレクトリ(相対パス)
# %n    ユーザ名
# %#    ユーザ種別
# %?    直前のコマンドの戻り値
# %D    日付(yy-mm-dd)
# %W    日付(yy/mm/dd)
# %w    日付(day dd)
# %*    時間(hh:flag_mm:ss)
# %T    時間(hh:mm)
# %t    時間(hh:mm(am/pm))
PROMPT='[%F{gray}%?%f] %F{cyan}%n@%m%f:%~# '

# promptテーマ設定
# prompt skwp
zstyle ':prezto:module:prompt' theme 'skwp'

# -----------------------------
# History
# -----------------------------
# 基本設定
HISTFILE=$HOME/.zsh-history
HISTSIZE=100000
SAVEHIST=1000000

# ヒストリーに重複を表示しない
setopt histignorealldups

# 他のターミナルとヒストリーを共有
setopt share_history

# すでにhistoryにあるコマンドは残さない
setopt hist_ignore_all_dups

# historyに日付を表示
alias h='fc -lt '%F %T' 1'

# ヒストリに保存するときに余分なスペースを削除する
setopt hist_reduce_blanks

# 履歴をすぐに追加する
setopt inc_append_history

# ヒストリを呼び出してから実行する間に一旦編集できる状態になる
setopt hist_verify
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion

# -----------------------------
# Load user specific settings
# -----------------------------
# load zshrc.local if exists
if [ -e $DOTFILES_DIR/.zshrc.local ]; then
    source $DOTFILES_DIR/.zshrc.local
fi
# load .env if exists
if [ -e $DOTFILES_DIR/.env ]; then
    source $DOTFILES_DIR/.env
fi
