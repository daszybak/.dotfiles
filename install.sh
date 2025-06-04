
# install.sh - Cross-platform dotfiles installer

set -euo pipefail

# Configuration
DOTFILES_REPO="git@github.com:daszybak/.dotfiles.git"
DOTFILES_DIR="$HOME/.dotfiles"
BACKUP_DIR="$HOME/.dotfiles-$(date +%Y%m%d-%H%M%S)"

# Parse arguments
FORCE_YES=false
INTERACTIVE=true

usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "Install dotfiles configuration"
    echo ""
    echo "OPTIONS:"
    echo "    -y, --yes           Auto-answer yes to all prompts"
    echo "    -i, --interactive   Interactive mode (default)"
    echo "    -h, --help          Show this help message"
    echo ""
    echo "Examples:"
    echo "    $0                # Interactive installation"
    echo "    $0 -y             # Force yes to all prompts"
    echo "    curl -fsSL https://raw.githubusercontent.com/daszybak/.dotfiles/main/install.sh | bash -s -- -y"
}

while [[ $# -gt 0 ]]; do
    case $1 in
        -y|--yes) FORCE_YES=true; INTERACTIVE=false; shift;;
        -i|--interactive) INTERACTIVE=true; FORCE_YES=false; shift;;
        -h|--help) usage; exit 0;;
        *) echo "Unknown option: $1" >&2; usage; exit 1;;
    esac
done

log() { echo "[+] $*"; }
warn() { echo "[!] $*" >&2; }
error() { echo "[x] $*" >&2; exit 1; }

confirm() {
    local prompt="$1"
    if [[ "$FORCE_YES" == true ]]; then
        log "$prompt [auto-yes]"
        return 1 # skip optional stuff in force mode
    fi
    while true; do
        read -rp "$prompt [Y/n] " response
        case "${response,,}" in
            y|yes|'') return 0;;
            n|no) return 1;;
            *) echo "Please answer y or n.";;
        esac
    done
}

# Detect platform
case "$(uname -s)" in
    Linux*) [[ -n "${WSL_DISTRO_NAME:-}" || $(grep -qi microsoft /proc/version) ]] && PLATFORM="wsl" || PLATFORM="linux";;
    Darwin*) PLATFORM="macos";;
    *) PLATFORM="unknown";;
esac
log "Platform detected: $PLATFORM"

# Clone dotfiles repo
if [[ ! -d "$DOTFILES_DIR" ]]; then
    if confirm "Clone dotfiles repository?"; then
        log "Cloning dotfiles..."
        git clone "$DOTFILES_REPO" "$DOTFILES_DIR" || error "Failed to clone repository"
    else
        error "Dotfiles repository required"
    fi
fi

cd "$DOTFILES_DIR"

# Backup existing dotfiles
backup_files() {
    local files=(".bashrc" ".zshrc" ".gitconfig" ".vimrc" ".tmux.conf")
    mkdir -p "$BACKUP_DIR"
    for file in "${files[@]}"; do
        if [[ -e "$HOME/$file" && ! -L "$HOME/$file" ]]; then
            log "Backing up $file to $BACKUP_DIR"
            mv "$HOME/$file" "$BACKUP_DIR/"
        fi
    done
}
backup_files

# Deploy dotfiles (fallback if stow not used)
deploy_symlinks() {
    ln -sf "$DOTFILES_DIR/bash/.bashrc" "$HOME/.bashrc"
    ln -sf "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
    ln -sf "$DOTFILES_DIR/git/.gitconfig" "$HOME/.gitconfig"
    ln -sf "$DOTFILES_DIR/tmux/.tmux.conf" "$HOME/.tmux.conf"
    ln -sf "$DOTFILES_DIR/vim/.vimrc" "$HOME/.vimrc"
    mkdir -p "$HOME/.config"
    ln -sf "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"
    mkdir -p "$HOME/.ssh"
    [[ -f "$DOTFILES_DIR/ssh/config" ]] && ln -sf "$DOTFILES_DIR/ssh/config" "$HOME/.ssh/config"
}

# ── Deploy dotfiles ────────────────────────────────────────────────
if confirm "Deploy dotfiles configuration?"; then
    log "Deploying dotfiles..."

    if command -v stow &> /dev/null && [[ "$FORCE_YES" == false ]]; then
        log "Using stow to manage symlinks"
        for pkg in bash zsh git tmux vim nvim ssh; do
            if [[ -d "$DOTFILES_DIR/$pkg" ]]; then
	    	stow --adopt --target="$HOME" "$pkg" || warn "Conflict detected with '$pkg'. Resolve manually."
            else
                warn "Package '$pkg' not found – skipped"
            fi
        done
    else
        log "Using manual symlink deployment"
        deploy_symlinks
    fi
fi

# Summary of Stow vs. Manual:
# Stow creates symlinks like:
# ~/.bashrc -> ~/.dotfiles/bash/.bashrc
# It handles folders modularly and is easily reversible (stow -D)
# In force mode we skip stow to avoid external dependencies

log "Dotfiles installation complete. Restart your shell or source ~/.bashrc or ~/.zshrc"

