
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

# Clone dotfiles repo or use current directory if already in dotfiles
if [[ ! -d "$DOTFILES_DIR" ]]; then
    # Check if we're already in a dotfiles directory (for CI/development)
    if [[ "$(basename "$PWD")" == ".dotfiles" && -f "$PWD/install.sh" ]]; then
        log "Already in dotfiles directory, using current location"
        DOTFILES_DIR="$PWD"
    elif confirm "Clone dotfiles repository?"; then
        log "Cloning dotfiles..."
        git clone "$DOTFILES_REPO" "$DOTFILES_DIR" || error "Failed to clone repository"
    elif [[ "$FORCE_YES" == true ]]; then
        # In force mode, if we can't clone and we're not in dotfiles dir, try current dir
        if [[ -f "$PWD/install.sh" ]]; then
            log "Force mode: using current directory as dotfiles"
            DOTFILES_DIR="$PWD"
        else
            error "Cannot determine dotfiles location in force mode"
        fi
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
    log "Creating symlinks manually..."
    
    # Bash configuration
    [[ -f "$DOTFILES_DIR/bash/.bashrc" ]] && ln -sf "$DOTFILES_DIR/bash/.bashrc" "$HOME/.bashrc" && log "Linked .bashrc"
    
    # Zsh configuration
    [[ -f "$DOTFILES_DIR/zsh/.zshrc" ]] && ln -sf "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc" && log "Linked .zshrc"
    
    # Git configuration
    [[ -f "$DOTFILES_DIR/git/.gitconfig" ]] && ln -sf "$DOTFILES_DIR/git/.gitconfig" "$HOME/.gitconfig" && log "Linked .gitconfig"
    
    # Tmux configuration
    [[ -f "$DOTFILES_DIR/tmux/.tmux.conf" ]] && ln -sf "$DOTFILES_DIR/tmux/.tmux.conf" "$HOME/.tmux.conf" && log "Linked .tmux.conf"
    
    # Vim configuration
    [[ -f "$DOTFILES_DIR/vim/.vimrc" ]] && ln -sf "$DOTFILES_DIR/vim/.vimrc" "$HOME/.vimrc" && log "Linked .vimrc"
    
    # Neovim configuration
    if [[ -d "$DOTFILES_DIR/nvim" ]]; then
        mkdir -p "$HOME/.config"
        ln -sf "$DOTFILES_DIR/nvim" "$HOME/.config/nvim" && log "Linked neovim config"
    fi
    

}

# ── Deploy dotfiles ────────────────────────────────────────────────
if confirm "Deploy dotfiles configuration?"; then
    log "Deploying dotfiles..."

    if command -v stow &> /dev/null; then
        if [[ "$FORCE_YES" == true ]] || confirm "Use stow for managing symlinks?"; then
            log "Using stow to manage symlinks"
            for pkg in bash zsh git tmux vim; do
                if [[ -d "$DOTFILES_DIR/$pkg" ]]; then
                    log "Stowing package: $pkg"
                    stow --adopt --target="$HOME" "$pkg" || warn "Conflict detected with '$pkg'. Resolve manually."
                else
                    warn "Package '$pkg' not found – skipped"
                fi
            done
            
            # Handle nvim separately since it goes to ~/.config
            if [[ -d "$DOTFILES_DIR/nvim" ]]; then
                log "Stowing nvim to ~/.config"
                mkdir -p "$HOME/.config"
                ln -sf "$DOTFILES_DIR/nvim" "$HOME/.config/nvim" && log "Linked neovim config"
            fi
        else
            log "Using manual symlink deployment"
            deploy_symlinks
        fi
    else
        log "Stow not found, using manual symlink deployment"
        deploy_symlinks
    fi
fi

# Summary of Stow vs. Manual:
# Stow creates symlinks like:
# ~/.bashrc -> ~/.dotfiles/bash/.bashrc
# It handles folders modularly and is easily reversible (stow -D)
# In force mode we skip stow to avoid external dependencies

# ── Source shell configuration ────────────────────────────────────────
log "Dotfiles installation complete!"

if [[ "$INTERACTIVE" == true ]] && confirm "Source shell configuration now?"; then
    # Detect current shell and source appropriate config
    case "$SHELL" in
        */zsh)
            if [[ -f "$HOME/.zshrc" ]]; then
                log "Sourcing .zshrc..."
                # Note: source in subshell to avoid exit on error
                (source "$HOME/.zshrc" 2>/dev/null) && log "Successfully sourced .zshrc" || warn "Error sourcing .zshrc"
            fi
            ;;
        */bash)
            if [[ -f "$HOME/.bashrc" ]]; then
                log "Sourcing .bashrc..."
                (source "$HOME/.bashrc" 2>/dev/null) && log "Successfully sourced .bashrc" || warn "Error sourcing .bashrc"
            fi
            ;;
        *)
            warn "Unknown shell: $SHELL"
            ;;
    esac
    
    log "Configuration loaded! Open a new terminal or run 'exec \$SHELL' to reload completely."
else
    log "Restart your shell or run 'exec \$SHELL' to load the new configuration"
fi

# ── Optional: Install Language Servers ────────────────────────────────────
if [[ "$INTERACTIVE" == true ]] && confirm "Install language servers for development?"; then
    if [[ -x "$DOTFILES_DIR/scripts/install-language-servers.sh" ]]; then
        log "Running language server installer..."
        "$DOTFILES_DIR/scripts/install-language-servers.sh"
    else
        warn "Language server installer not found or not executable"
    fi
fi

