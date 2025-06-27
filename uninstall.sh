#!/usr/bin/env bash
# uninstall.sh – cleanly remove dotfile links / stow packages

set -euo pipefail

DOTFILES_DIR="$HOME/.dotfiles"
BACKUP_DIR="$HOME/.dotfiles-backup"

log()  { echo -e "[+] $*"; }
warn() { echo -e "[!] $*" >&2; }

echo "⚠️  This will remove symlinks created by install.sh and restore backups if available."
read -rp "Proceed? [y/N] " ans
[[ "${ans,,}" =~ ^(y|yes)$ ]] || { echo "Aborted."; exit 0; }

# ── Unstow dotfiles ────────────────────────────────────────────────
if command -v stow &> /dev/null; then
    for pkg in bash zsh git tmux vim ssh skhd aerospace; do
        if [[ -d "$DOTFILES_DIR/$pkg" ]]; then
            log "Unstowing $pkg from $HOME"
            stow -D --target="$HOME" "$pkg" || warn "Unstow failed for $pkg"
        fi
    done
    if [[ -d "$DOTFILES_DIR/nvim" ]]; then
        log "Unstowing nvim from $HOME/.config"
        stow -D --target="$HOME/.config" nvim || warn "Unstow failed for nvim"
    fi
else
    warn "GNU stow not found – skipping unstow step."
fi

# ── Remove manual or leftover links ────────────────────────────────
remove_link() {
    local path="$1"
    if [[ -L "$path" || -f "$path" || -d "$path" ]]; then
        log "Removing $path"
        rm -rf "$path"
    fi
}

for file in \
    "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.gitconfig" \
    "$HOME/.tmux.conf" "$HOME/.vimrc" "$HOME/.ssh/config" \
    "$HOME/.config/nvim"
do
    remove_link "$file"
done

# ── Restore backup if present ──────────────────────────────────────
if [[ -d "$BACKUP_DIR" ]]; then
    log "Restoring backups from $BACKUP_DIR"
    cp -r "$BACKUP_DIR"/. "$HOME"/
else
    warn "No backup directory found – nothing to restore."
fi

log "✅ Uninstall complete. You may now delete $DOTFILES_DIR if desired."

