#!/usr/bin/env bash
set -eu

# Lint script for dotfiles project
# Supports: shell, lua, json, yaml, toml, python

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

warn_echo() {
    echo -e "\033[33m$(date '+%Y-%m-%d %H:%M:%S') [WARN] $1\033[0m"
}

lint_shell() {
    info_echo "Linting Shell scripts..."
    if command -v shellcheck >/dev/null 2>&1; then
        if [[ ${#FILES_TO_LINT[@]} -gt 0 ]]; then
            # Lint only specified files
            for file in "${FILES_TO_LINT[@]}"; do
                if [[ "$file" == *.sh ]]; then
                    shellcheck --external-sources "$file"
                fi
            done
        else
            # Lint all shell files
            cd "$DOTFILES_DIR"
            eval "find . -name '*.sh' $EXCLUDE_PATHS -exec shellcheck --external-sources {} +"
        fi
    else
        err_echo "shellcheck not found. Install with package manager"
        return 1
    fi
}

lint_lua() {
    info_echo "Linting Lua files..."
    if command -v luacheck >/dev/null 2>&1; then
        eval "find \"$DOTFILES_DIR\" -name '*.lua' $EXCLUDE_PATHS -exec luacheck {} +"
    else
        warn_echo "luacheck not found. Install with: luarocks install luacheck (optional)"
    fi
}

lint_json() {
    info_echo "Checking JSON files..."
    local json_error=0
    while IFS= read -r -d '' file; do
        if ! python3 -m json.tool "$file" >/dev/null 2>&1; then
            err_echo "JSON syntax error in: $file"
            json_error=1
        fi
    done < <(eval "find \"$DOTFILES_DIR\" -name '*.json' $EXCLUDE_PATHS -print0")

    if [[ $json_error -eq 1 ]]; then
        return 1
    fi
}

lint_yaml() {
    info_echo "Checking YAML files..."
    if command -v yamllint >/dev/null 2>&1; then
        eval "find \"$DOTFILES_DIR\" \( -name '*.yaml' -o -name '*.yml' \) $EXCLUDE_PATHS -exec yamllint {} +"
    elif [ -f "$DOTFILES_DIR/.venv/bin/yamllint" ]; then
        eval "find \"$DOTFILES_DIR\" \( -name '*.yaml' -o -name '*.yml' \) $EXCLUDE_PATHS -exec \"$DOTFILES_DIR/.venv/bin/yamllint\" {} +"
    else
        warn_echo "yamllint not found. Install with: pip install yamllint"
    fi
}

lint_toml() {
    info_echo "Checking TOML files..."
    if command -v taplo >/dev/null 2>&1; then
        eval "find \"$DOTFILES_DIR\" -name '*.toml' $EXCLUDE_PATHS -exec taplo check {} +"
    else
        warn_echo "taplo not found. Install with: cargo install taplo-cli (optional)"
    fi
}

lint_python() {
    info_echo "Linting Python files..."
    local python_error=0

    if [ -f "$DOTFILES_DIR/.venv/bin/flake8" ]; then
        cd "$DOTFILES_DIR"
        if ! .venv/bin/flake8 .; then
            python_error=1
        fi
    else
        err_echo "flake8 not found. Run: make install"
        python_error=1
    fi

    if [ -f "$DOTFILES_DIR/.venv/bin/mypy" ]; then
        cd "$DOTFILES_DIR"
        if ! .venv/bin/mypy . --ignore-missing-imports; then
            python_error=1
        fi
    else
        err_echo "mypy not found. Run: make install"
        python_error=1
    fi

    if [[ $python_error -eq 1 ]]; then
        return 1
    fi
}

show_help() {
    echo "Usage: $0 [OPTIONS] [FILES...]"
    echo "Lint code files in the dotfiles project"
    echo ""
    echo "Options:"
    echo "  -s, --shell     Lint Shell scripts only"
    echo "  -l, --lua       Lint Lua files only"
    echo "  -j, --json      Check JSON files only"
    echo "  -y, --yaml      Check YAML files only"
    echo "  -t, --toml      Check TOML files only"
    echo "  -p, --python    Lint Python files only"
    echo "  -h, --help      Show this help message"
    echo ""
    echo "If no options are provided, all supported file types will be linted"
    echo "If files are provided, only those files will be processed"
}

# Parse command line arguments
LINT_ALL=true
LINT_SHELL=false
LINT_LUA=false
LINT_JSON=false
LINT_YAML=false
LINT_TOML=false
LINT_PYTHON=false
FILES_TO_LINT=()

while [[ $# -gt 0 ]]; do
    case $1 in
        -s|--shell)
            LINT_ALL=false
            LINT_SHELL=true
            shift
            ;;
        -l|--lua)
            LINT_ALL=false
            LINT_LUA=true
            shift
            ;;
        -j|--json)
            LINT_ALL=false
            LINT_JSON=true
            shift
            ;;
        -y|--yaml)
            LINT_ALL=false
            LINT_YAML=true
            shift
            ;;
        -t|--toml)
            LINT_ALL=false
            LINT_TOML=true
            shift
            ;;
        -p|--python)
            LINT_ALL=false
            LINT_PYTHON=true
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
            # Files to lint
            FILES_TO_LINT+=("$1")
            shift
            ;;
    esac
done

# Track overall exit status
overall_status=0

# If files are specified, auto-detect type and lint only those files
if [[ ${#FILES_TO_LINT[@]} -gt 0 ]]; then
    for file in "${FILES_TO_LINT[@]}"; do
        case "$file" in
            *.sh)
                if command -v shellcheck >/dev/null 2>&1; then
                    shellcheck --external-sources "$file" || overall_status=1
                else
                    err_echo "shellcheck not found for $file"
                    overall_status=1
                fi
                ;;
            *.lua)
                if command -v luacheck >/dev/null 2>&1; then
                    luacheck "$file" || true
                fi
                ;;
            *.json)
                if ! python3 -m json.tool "$file" >/dev/null 2>&1; then
                    err_echo "JSON syntax error in: $file"
                    overall_status=1
                fi
                ;;
            *.yaml|*.yml)
                if command -v yamllint >/dev/null 2>&1; then
                    yamllint "$file" || true
                elif [ -f "$DOTFILES_DIR/.venv/bin/yamllint" ]; then
                    "$DOTFILES_DIR/.venv/bin/yamllint" "$file" || true
                fi
                ;;
            *.toml)
                if command -v taplo >/dev/null 2>&1; then
                    taplo check "$file" || true
                fi
                ;;
            *.py)
                if [ -f "$DOTFILES_DIR/.venv/bin/flake8" ]; then
                    "$DOTFILES_DIR/.venv/bin/flake8" "$file" || overall_status=1
                fi
                if [ -f "$DOTFILES_DIR/.venv/bin/mypy" ]; then
                    "$DOTFILES_DIR/.venv/bin/mypy" "$file" --ignore-missing-imports || overall_status=1
                fi
                ;;
        esac
    done
elif [[ "$LINT_ALL" == true ]]; then
    lint_shell || overall_status=1
    lint_lua || true  # Optional linter
    lint_json || overall_status=1
    lint_yaml || true  # May not be available
    lint_toml || true  # Optional linter
    lint_python || overall_status=1
else
    if [[ "$LINT_SHELL" == true ]]; then
        lint_shell || overall_status=1
    fi
    if [[ "$LINT_LUA" == true ]]; then
        lint_lua || true
    fi
    if [[ "$LINT_JSON" == true ]]; then
        lint_json || overall_status=1
    fi
    if [[ "$LINT_YAML" == true ]]; then
        lint_yaml || true
    fi
    if [[ "$LINT_TOML" == true ]]; then
        lint_toml || true
    fi
    if [[ "$LINT_PYTHON" == true ]]; then
        lint_python || overall_status=1
    fi
fi

if [[ $overall_status -eq 0 ]]; then
    info_echo "Linting passed!"
else
    err_echo "Some linting checks failed!"
fi

exit $overall_status
