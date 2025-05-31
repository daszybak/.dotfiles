#!/usr/bin/env bash
# uninstall.sh – cleanly remove dotfile links / stow packages
set -euo pipefail

DOTFILES_DIR="$HOME/.dotfiles"
BACKUP_DIR="$HOME/.dotfiles-backup"

log()  { echo "[+] $*"; }
warn() { echo "[!] $*" >&2; }

echo "⚠️  This will remove symlinks created by install.sh."
read -rp "Proceed? [y/N] " ans
[[ "${ans,,}" =~ ^(y|yes)$ ]] || { echo "Aborted."; exit 0; }

# ── If stow is present, unstow any packages that exist ─────────────
if command -v stow &> /dev/null; then
    for pkg in bash zsh git tmux vim nvim ssh; do
        [[ -d "$DOTFILES_DIR/$pkg" ]] && { log "unstow $pkg"; stow -D --target="$HOME" "$pkg"; }
    done
fi

# ── Remove manual links in case stow wasn’t used ───────────────────
remove_link() {
    local path="$1"
    [[ -L "$path" ]] && { log "unlink $path"; rm -f "$path"; }
}

remove_link "$HOME/.bashrc"
remove_link "$HOME/.zshrc"
remove_link "$HOME/.gitconfig"
remove_link "$HOME/.tmux.conf"
remove_link "$HOME/.vimrc"
remove_link "$HOME/.config/nvim"
remove_link "$HOME/.ssh/config"

# ── Restore backups if present ─────────────────────────────────────
if [[ -d "$BACKUP_DIR" ]]; then
    log "Restoring backups from $BACKUP_DIR"
    cp -r "$BACKUP_DIR"/. "$HOME"/
else
    warn "No backup directory found – nothing to restore."
fi

log "✅ Uninstall complete. You may delete $DOTFILES_DIR if desired."

