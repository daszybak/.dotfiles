#!/usr/bin/env bash
#
# uninstall.sh - Remove dotfiles symlinks and restore backups
#

set -euo pipefail

# ─────────────────────────────────────────────────────────────────────────────
# Configuration
# ─────────────────────────────────────────────────────────────────────────────

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
BACKUP_PATTERN="$HOME/.dotfiles-backup-*"

# ─────────────────────────────────────────────────────────────────────────────
# Logging
# ─────────────────────────────────────────────────────────────────────────────

log()   { printf '\033[0;32m[+]\033[0m %s\n' "$*"; }
warn()  { printf '\033[0;33m[!]\033[0m %s\n' "$*" >&2; }
error() { printf '\033[0;31m[x]\033[0m %s\n' "$*" >&2; exit 1; }

# ─────────────────────────────────────────────────────────────────────────────
# Confirmation
# ─────────────────────────────────────────────────────────────────────────────

echo ""
warn "This will remove all dotfile symlinks and optionally restore backups."
echo ""
read -rp "Continue? [y/N] " response
[[ "${response,,}" =~ ^y(es)?$ ]] || { echo "Aborted."; exit 0; }

# ─────────────────────────────────────────────────────────────────────────────
# Remove symlinks
# ─────────────────────────────────────────────────────────────────────────────

remove_symlink() {
    local target="$1"
    if [[ -L "$target" ]]; then
        log "Removing symlink: $target"
        rm -f "$target"
    elif [[ -e "$target" ]]; then
        warn "Not a symlink, skipping: $target"
    fi
}

log "Removing symlinks..."

# Home directory files
remove_symlink "$HOME/.bashrc"
remove_symlink "$HOME/.zshrc"
remove_symlink "$HOME/.gitconfig"
remove_symlink "$HOME/.vimrc"

# XDG config directory
remove_symlink "$HOME/.config/nvim"
remove_symlink "$HOME/.config/zellij"
remove_symlink "$HOME/.config/shell"
remove_symlink "$HOME/.claude"

# ─────────────────────────────────────────────────────────────────────────────
# Restore backups
# ─────────────────────────────────────────────────────────────────────────────

# Find the most recent backup
latest_backup=""
for backup in $BACKUP_PATTERN; do
    [[ -d "$backup" ]] && latest_backup="$backup"
done

if [[ -n "$latest_backup" && -d "$latest_backup" ]]; then
    echo ""
    read -rp "Restore from backup ($latest_backup)? [y/N] " response
    if [[ "${response,,}" =~ ^y(es)?$ ]]; then
        log "Restoring backups..."
        for file in "$latest_backup"/*; do
            [[ -e "$file" ]] || continue
            local_name=$(basename "$file")
            cp -r "$file" "$HOME/$local_name"
            log "Restored: $local_name"
        done
    fi
else
    log "No backup directory found."
fi

# ─────────────────────────────────────────────────────────────────────────────
# Done
# ─────────────────────────────────────────────────────────────────────────────

echo ""
log "Uninstall complete."
echo ""
echo "  The dotfiles repository is still at: $DOTFILES_DIR"
echo "  Remove it manually if you no longer need it:"
echo "    rm -rf $DOTFILES_DIR"
echo ""
