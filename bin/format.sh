#!/usr/bin/env bash
set -eu

# Format script for dotfiles project
# Supports: lua, shell, json, yaml, toml, markdown, python

SCRIPT_DIR=$(dirname "$(realpath "$0")")
DOTFILES_DIR=$(dirname "$SCRIPT_DIR")

# Common exclusion patterns
EXCLUDE_PATHS="-not -path './.venv/*' -not -path './build/*' -not -path './.zprezto/*' -not -path './config/claude/shell-snapshots/*' -not -path './tsumiki/*' -not -path './tmux/plugins/*' -not -path './.fzf/*' -not -path './.zplug/*'"

info_echo() {
    echo -e "\033[32m$(date '+%Y-%m-%d %H:%M:%S') [INFO] $1\033[0m"
}

err_echo() {
    echo -e "\033[31m$(date '+%Y-%m-%d %H:%M:%S') [ERROR] $1\033[0m"
}

format_lua() {
    info_echo "Formatting Lua files..."
    if command -v stylua >/dev/null 2>&1; then
        eval "find \"$DOTFILES_DIR\" -name '*.lua' $EXCLUDE_PATHS -exec stylua --config-path=\"$DOTFILES_DIR/.stylua.toml\" {} +"
    else
        err_echo "stylua not found. Install with: cargo install stylua"
        return 1
    fi
}

format_shell() {
    info_echo "Formatting Shell files..."
    if command -v shfmt >/dev/null 2>&1; then
        eval "find \"$DOTFILES_DIR\" -name '*.sh' $EXCLUDE_PATHS -exec shfmt -i 4 -w {} +"
    else
        info_echo "shfmt not found. Skipping shell formatting (install with: go install mvdan.cc/sh/v3/cmd/shfmt@latest)"
    fi
}

format_json_yaml_md() {
    info_echo "Formatting JSON, YAML, Markdown files..."
    if command -v prettier >/dev/null 2>&1; then
        cd "$DOTFILES_DIR"
        prettier --write "**/*.{json,yaml,yml,md}" --ignore-path .gitignore
    else
        err_echo "prettier not found. Install with: npm install -g prettier"
        return 1
    fi
}

format_toml() {
    info_echo "Formatting TOML files..."
    if command -v taplo >/dev/null 2>&1; then
        eval "find \"$DOTFILES_DIR\" -name '*.toml' $EXCLUDE_PATHS -exec taplo format {} +"
    else
        err_echo "taplo not found. Install with: cargo install taplo-cli"
        return 1
    fi
}

format_python() {
    info_echo "Formatting Python files..."
    if [ -f "$DOTFILES_DIR/.venv/bin/black" ]; then
        cd "$DOTFILES_DIR"
        .venv/bin/black .
        .venv/bin/isort .
    else
        err_echo "Python tools not found. Run: make install"
        return 1
    fi
}

show_help() {
    echo "Usage: $0 [OPTIONS] [FILES...]"
    echo "Format code files in the dotfiles project"
    echo ""
    echo "Options:"
    echo "  -l, --lua       Format Lua files only"
    echo "  -s, --shell     Format Shell scripts only"
    echo "  -j, --json-yaml Format JSON, YAML, Markdown files only"
    echo "  -t, --toml      Format TOML files only"
    echo "  -p, --python    Format Python files only"
    echo "  -h, --help      Show this help message"
    echo ""
    echo "If no options are provided, all supported file types will be formatted"
    echo "If files are provided, only those files will be processed"
}

# Parse command line arguments
FORMAT_ALL=true
FORMAT_LUA=false
FORMAT_SHELL=false
FORMAT_JSON_YAML=false
FORMAT_TOML=false
FORMAT_PYTHON=false
FILES_TO_FORMAT=()

while [[ $# -gt 0 ]]; do
    case $1 in
        -l|--lua)
            FORMAT_ALL=false
            FORMAT_LUA=true
            shift
            ;;
        -s|--shell)
            FORMAT_ALL=false
            FORMAT_SHELL=true
            shift
            ;;
        -j|--json-yaml)
            FORMAT_ALL=false
            FORMAT_JSON_YAML=true
            shift
            ;;
        -t|--toml)
            FORMAT_ALL=false
            FORMAT_TOML=true
            shift
            ;;
        -p|--python)
            FORMAT_ALL=false
            FORMAT_PYTHON=true
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        -*)
            err_echo "Unknown option: $1"
            show_help
            exit 1
            ;;
        *)
            # Files to format
            FILES_TO_FORMAT+=("$1")
            shift
            ;;
    esac
done

# If files are specified, auto-detect type and format only those files
if [[ ${#FILES_TO_FORMAT[@]} -gt 0 ]]; then
    for file in "${FILES_TO_FORMAT[@]}"; do
        case "$file" in
            *.lua)
                if command -v stylua >/dev/null 2>&1; then
                    stylua --config-path="$DOTFILES_DIR/.stylua.toml" "$file"
                fi
                ;;
            *.sh)
                if command -v shfmt >/dev/null 2>&1; then
                    shfmt -i 4 -w "$file"
                fi
                ;;
            *.json|*.yaml|*.yml|*.md)
                if command -v prettier >/dev/null 2>&1; then
                    prettier --write "$file"
                fi
                ;;
            *.toml)
                if command -v taplo >/dev/null 2>&1; then
                    taplo format "$file"
                fi
                ;;
            *.py)
                if [ -f "$DOTFILES_DIR/.venv/bin/black" ]; then
                    "$DOTFILES_DIR/.venv/bin/black" "$file"
                fi
                if [ -f "$DOTFILES_DIR/.venv/bin/isort" ]; then
                    "$DOTFILES_DIR/.venv/bin/isort" "$file"
                fi
                ;;
        esac
    done
    info_echo "File formatting completed!"
elif [[ "$FORMAT_ALL" == true ]]; then
    format_lua
    format_shell
    format_json_yaml_md
    format_toml
    format_python
    info_echo "All formatting completed!"
else
    if [[ "$FORMAT_LUA" == true ]]; then
        format_lua
    fi
    if [[ "$FORMAT_SHELL" == true ]]; then
        format_shell
    fi
    if [[ "$FORMAT_JSON_YAML" == true ]]; then
        format_json_yaml_md
    fi
    if [[ "$FORMAT_TOML" == true ]]; then
        format_toml
    fi
    if [[ "$FORMAT_PYTHON" == true ]]; then
        format_python
    fi
    info_echo "Selected formatting completed!"
fi
