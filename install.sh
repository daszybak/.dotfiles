#!/usr/bin/env bash
#
# install.sh - Cross-platform dotfiles installer
#
# Usage:
#   ./install.sh          # Interactive installation
#   ./install.sh -y       # Auto-accept all prompts
#   curl -fsSL <url> | bash -s -- -y
#

set -euo pipefail

# ─────────────────────────────────────────────────────────────────────────────
# Configuration
# ─────────────────────────────────────────────────────────────────────────────

DOTFILES_REPO="git@github.com:daszybak/.dotfiles.git"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

# ─────────────────────────────────────────────────────────────────────────────
# Logging
# ─────────────────────────────────────────────────────────────────────────────

log()   { printf '\033[0;32m[+]\033[0m %s\n' "$*"; }
warn()  { printf '\033[0;33m[!]\033[0m %s\n' "$*" >&2; }
error() { printf '\033[0;31m[x]\033[0m %s\n' "$*" >&2; exit 1; }

# ─────────────────────────────────────────────────────────────────────────────
# Argument parsing
# ─────────────────────────────────────────────────────────────────────────────

AUTO_YES=false

show_help() {
    cat << 'EOF'
Usage: install.sh [OPTIONS]

Install dotfiles configuration for macOS and Linux.

Options:
    -y, --yes       Auto-accept all prompts
    -h, --help      Show this help message

Examples:
    ./install.sh              # Interactive mode
    ./install.sh -y           # Non-interactive mode
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -y|--yes)   AUTO_YES=true; shift ;;
        -h|--help)  show_help; exit 0 ;;
        *)          error "Unknown option: $1" ;;
    esac
done

# ─────────────────────────────────────────────────────────────────────────────
# Helper functions
# ─────────────────────────────────────────────────────────────────────────────

confirm() {
    local prompt="$1"
    [[ "$AUTO_YES" == true ]] && return 0
    read -rp "$prompt [Y/n] " response
    [[ -z "$response" || "${response,,}" =~ ^y(es)?$ ]]
}

detect_platform() {
    case "$(uname -s)" in
        Darwin) echo "macos" ;;
        Linux)
            if [[ -n "${WSL_DISTRO_NAME:-}" ]] || grep -qi microsoft /proc/version 2>/dev/null; then
                echo "wsl"
            else
                echo "linux"
            fi
            ;;
        *) echo "unknown" ;;
    esac
}

command_exists() {
    command -v "$1" &>/dev/null
}

# ─────────────────────────────────────────────────────────────────────────────
# Symlink management
# ─────────────────────────────────────────────────────────────────────────────

backup_if_exists() {
    local target="$1"
    if [[ -e "$target" && ! -L "$target" ]]; then
        mkdir -p "$BACKUP_DIR"
        log "Backing up: $target → $BACKUP_DIR/"
        mv "$target" "$BACKUP_DIR/"
    elif [[ -L "$target" ]]; then
        rm -f "$target"
    fi
}

create_symlink() {
    local source="$1"
    local target="$2"

    [[ ! -e "$source" ]] && return 0

    backup_if_exists "$target"
    ln -sf "$source" "$target"
    log "Linked: $(basename "$target")"
}

# ─────────────────────────────────────────────────────────────────────────────
# Deployment
# ─────────────────────────────────────────────────────────────────────────────

deploy_dotfiles() {
    log "Deploying dotfiles..."

    # Shell configs → home directory
    create_symlink "$DOTFILES_DIR/bash/.bashrc"     "$HOME/.bashrc"
    create_symlink "$DOTFILES_DIR/zsh/.zshrc"       "$HOME/.zshrc"

    # Git config
    create_symlink "$DOTFILES_DIR/git/.gitconfig"   "$HOME/.gitconfig"

    # Vim
    create_symlink "$DOTFILES_DIR/vim/.vimrc"       "$HOME/.vimrc"

    # XDG config directory apps
    mkdir -p "$HOME/.config"

    # Neovim
    if [[ -d "$DOTFILES_DIR/nvim" ]]; then
        backup_if_exists "$HOME/.config/nvim"
        ln -sf "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"
        log "Linked: nvim config"
    fi

    # Zellij (replaces tmux)
    if [[ -d "$DOTFILES_DIR/zellij" ]]; then
        backup_if_exists "$HOME/.config/zellij"
        ln -sf "$DOTFILES_DIR/zellij" "$HOME/.config/zellij"
        log "Linked: zellij config"
    fi

    # Claude Code
    if [[ -d "$DOTFILES_DIR/claude" ]]; then
        backup_if_exists "$HOME/.claude"
        ln -sf "$DOTFILES_DIR/claude" "$HOME/.claude"
        log "Linked: claude config"
    fi

    # Shell modules → ~/.config/shell
    if [[ -d "$DOTFILES_DIR/shell" ]]; then
        backup_if_exists "$HOME/.config/shell"
        ln -sf "$DOTFILES_DIR/shell" "$HOME/.config/shell"
        log "Linked: shell modules"
    fi
}

# ─────────────────────────────────────────────────────────────────────────────
# Package installation
# ─────────────────────────────────────────────────────────────────────────────

install_packages() {
    local platform="$1"

    log "Installing essential packages..."

    case "$platform" in
        macos)
            if ! command_exists brew; then
                warn "Homebrew not found. Install from https://brew.sh"
                warn "Skipping package installation..."
                return 0
            fi
            brew install zellij neovim ripgrep fd fzf git-delta lazygit || true
            ;;
        linux|wsl)
            if command_exists apt-get; then
                sudo apt-get update -qq
                sudo apt-get install -y neovim ripgrep fd-find fzf || true
                # Zellij via cargo or binary
                if ! command_exists zellij && command_exists cargo; then
                    cargo install zellij || true
                fi
            elif command_exists dnf; then
                sudo dnf install -y neovim ripgrep fd-find fzf || true
            elif command_exists pacman; then
                sudo pacman -S --noconfirm neovim ripgrep fd fzf zellij || true
            fi
            ;;
    esac
}

install_claude_code() {
    log "Installing Claude Code..."

    if command_exists claude; then
        log "Claude Code already installed"
        return 0
    fi

    curl -fsSL https://claude.ai/install.sh | bash

    log "Claude Code installed. Run 'claude' to authenticate and start."
}

# ─────────────────────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────────────────────

main() {
    local platform
    platform=$(detect_platform)
    log "Platform: $platform"

    # Clone or locate dotfiles
    if [[ ! -d "$DOTFILES_DIR" ]]; then
        if [[ -f "./install.sh" && -d "./nvim" ]]; then
            DOTFILES_DIR="$PWD"
            log "Using current directory as dotfiles"
        elif confirm "Clone dotfiles repository?"; then
            log "Cloning dotfiles..."
            git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
        else
            error "Dotfiles directory not found"
        fi
    fi

    cd "$DOTFILES_DIR"

    # Deploy symlinks
    if confirm "Deploy dotfiles?"; then
        deploy_dotfiles
    fi

    # Install packages
    if confirm "Install packages (zellij, neovim, ripgrep, etc.)?"; then
        install_packages "$platform"
    fi

    # Install Claude Code
    if confirm "Install Claude Code CLI?"; then
        install_claude_code
    fi

    # Done
    echo ""
    log "Installation complete!"
    echo ""
    echo "  Next steps:"
    echo "    1. Restart your shell:  exec \$SHELL"
    echo "    2. Open Neovim:         nvim"
    echo "    3. Start Zellij:        zellij"
    echo "    4. Authenticate Claude: claude"
    echo ""

    if [[ -d "$BACKUP_DIR" ]]; then
        echo "  Backups saved to: $BACKUP_DIR"
        echo ""
    fi
}

main "$@"
