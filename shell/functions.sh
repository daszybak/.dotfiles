# shell/functions.sh
# Cross-platform shell functions

# ── Load zellij helper (tmux migration) ──────────────────────────────────────
if [[ -f "$HOME/.dotfiles/scripts/zellij-helper.sh" ]]; then
    source "$HOME/.dotfiles/scripts/zellij-helper.sh"
fi

# ── Directory creation and navigation ────────────────────────────────────────
mkcd() {
    mkdir -p "$1" && cd "$1" || return
}

# ── Quick file search ────────────────────────────────────────────────────────
ff() {
    if command -v fd &>/dev/null; then
        fd "$@"
    else
        find . -name "*$1*" 2>/dev/null
    fi
}

# ── Quick content search ─────────────────────────────────────────────────────
rgg() {
    if command -v rg &>/dev/null; then
        rg --hidden --smart-case "$@"
    else
        grep -r "$@" .
    fi
}

# ── Git quick commit ─────────────────────────────────────────────────────────
gcm() {
    git add -A && git commit -m "$*"
}

# ── Extract any archive ──────────────────────────────────────────────────────
extract() {
    if [[ -f "$1" ]]; then
        case "$1" in
            *.tar.bz2)  tar xjf "$1" ;;
            *.tar.gz)   tar xzf "$1" ;;
            *.tar.xz)   tar xJf "$1" ;;
            *.bz2)      bunzip2 "$1" ;;
            *.gz)       gunzip "$1" ;;
            *.tar)      tar xf "$1" ;;
            *.tbz2)     tar xjf "$1" ;;
            *.tgz)      tar xzf "$1" ;;
            *.zip)      unzip "$1" ;;
            *.Z)        uncompress "$1" ;;
            *.7z)       7z x "$1" ;;
            *.rar)      unrar x "$1" ;;
            *)          echo "'$1' cannot be extracted" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# ── Claude Code helpers ──────────────────────────────────────────────────────
# Start claude in the current git repo
claude-here() {
    if git rev-parse --git-dir &>/dev/null; then
        claude
    else
        echo "Not in a git repository"
        return 1
    fi
}

# Quick chat with Claude
ask() {
    claude chat "$*"
}

# ── Quick HTTP server ────────────────────────────────────────────────────────
serve() {
    local port="${1:-8000}"
    if command -v python3 &>/dev/null; then
        python3 -m http.server "$port"
    elif command -v python &>/dev/null; then
        python -m SimpleHTTPServer "$port"
    else
        echo "Python not found"
    fi
}

# ── JSON pretty print ────────────────────────────────────────────────────────
json() {
    if command -v jq &>/dev/null; then
        jq '.' "$@"
    elif command -v python3 &>/dev/null; then
        python3 -m json.tool "$@"
    else
        cat "$@"
    fi
}

# ── Weather ──────────────────────────────────────────────────────────────────
weather() {
    curl -s "wttr.in/${1:-}"
}

# ── Quick notes ──────────────────────────────────────────────────────────────
note() {
    local notes_dir="$HOME/notes"
    mkdir -p "$notes_dir"
    local file="$notes_dir/$(date +%Y-%m-%d).md"
    if [[ $# -eq 0 ]]; then
        nvim "$file"
    else
        echo "- $(date +%H:%M) $*" >> "$file"
        echo "Note added to $file"
    fi
}

# ── Cheatsheet ───────────────────────────────────────────────────────────────
cheat() {
    curl -s "cheat.sh/$1"
}

