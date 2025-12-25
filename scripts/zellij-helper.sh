#!/usr/bin/env bash
#
# zellij-helper.sh - Zellij power functions for tmux migrants
#
# Source this in your shell: source ~/.config/shell/zellij-helper.sh
# Or it's automatically loaded via functions.sh
#

# ─────────────────────────────────────────────────────────────────────────────
# Session Management (tmux-like)
# ─────────────────────────────────────────────────────────────────────────────

# Start or attach to session (like tmux new -A -s)
zs() {
    local session="${1:-$(basename "$PWD")}"
    
    if [[ -z "$ZELLIJ" ]]; then
        # Not inside zellij - attach or create
        if zellij list-sessions 2>/dev/null | grep -q "^$session"; then
            zellij attach "$session"
        else
            zellij --session "$session"
        fi
    else
        echo "Already inside Zellij session: $ZELLIJ_SESSION_NAME"
        echo "Use 'zjls' to list sessions, 'zjsw' to switch"
    fi
}

# Start with dev layout (editor + claude pane)
zdev() {
    local session="${1:-$(basename "$PWD")-dev}"
    
    if [[ -z "$ZELLIJ" ]]; then
        zellij --session "$session" --layout dev
    else
        echo "Already inside Zellij. Opening dev layout in new tab..."
        zellij action new-tab --layout dev
    fi
}

# List sessions (like tmux ls)
zjls() {
    if zellij list-sessions 2>/dev/null; then
        return 0
    else
        echo "No active Zellij sessions"
        return 1
    fi
}

# Kill a session (like tmux kill-session -t)
zjkill() {
    local session="$1"
    
    if [[ -z "$session" ]]; then
        echo "Usage: zjkill <session-name>"
        echo ""
        echo "Active sessions:"
        zjls
        return 1
    fi
    
    zellij kill-session "$session" && echo "Killed session: $session"
}

# Kill all sessions (like tmux kill-server)
zjkillall() {
    local sessions
    sessions=$(zellij list-sessions 2>/dev/null)
    
    if [[ -z "$sessions" ]]; then
        echo "No sessions to kill"
        return 0
    fi
    
    echo "This will kill all Zellij sessions:"
    echo "$sessions"
    echo ""
    read -rp "Continue? [y/N] " response
    [[ "${response,,}" =~ ^y(es)?$ ]] || return 0
    
    zellij kill-all-sessions
    echo "All sessions killed"
}

# Interactive session picker (like tmux choose-tree)
zj() {
    local sessions
    sessions=$(zellij list-sessions 2>/dev/null)
    
    if [[ -n "$ZELLIJ" ]]; then
        echo "Already inside Zellij session: $ZELLIJ_SESSION_NAME"
        echo ""
        echo "Commands:"
        echo "  Ctrl+b d    - Detach from session"
        echo "  zjls        - List all sessions"
        echo ""
        return 0
    fi
    
    if [[ -z "$sessions" ]]; then
        echo "No active sessions. Starting new session..."
        zs
        return
    fi
    
    if command -v fzf &>/dev/null; then
        local selected
        selected=$(echo "$sessions" | fzf --height=40% --reverse --header="Select session (or Esc for new)")
        
        if [[ -n "$selected" ]]; then
            zellij attach "$selected"
        else
            read -rp "New session name [$(basename "$PWD")]: " name
            zs "${name:-$(basename "$PWD")}"
        fi
    else
        echo "Active sessions:"
        echo "$sessions"
        echo ""
        read -rp "Attach to session (or Enter for new): " name
        if [[ -n "$name" ]]; then
            zellij attach "$name"
        else
            zs
        fi
    fi
}

# ─────────────────────────────────────────────────────────────────────────────
# Zellij Actions (run from inside zellij)
# ─────────────────────────────────────────────────────────────────────────────

# Create new pane (like tmux split-window)
zjsplit() {
    if [[ -z "$ZELLIJ" ]]; then
        echo "Not inside Zellij"
        return 1
    fi
    
    local direction="${1:-down}"
    case "$direction" in
        h|horizontal|down|-) zellij action new-pane --direction down ;;
        v|vertical|right|\|) zellij action new-pane --direction right ;;
        *) echo "Usage: zjsplit [h|v|horizontal|vertical]" ;;
    esac
}

# New tab (like tmux new-window)
zjtab() {
    if [[ -z "$ZELLIJ" ]]; then
        echo "Not inside Zellij"
        return 1
    fi
    
    local name="$1"
    if [[ -n "$name" ]]; then
        zellij action new-tab --name "$name"
    else
        zellij action new-tab
    fi
}

# Rename current tab (like tmux rename-window)
zjrename() {
    if [[ -z "$ZELLIJ" ]]; then
        echo "Not inside Zellij"
        return 1
    fi
    
    local name="$1"
    if [[ -z "$name" ]]; then
        read -rp "New tab name: " name
    fi
    
    zellij action rename-tab "$name"
}

# ─────────────────────────────────────────────────────────────────────────────
# Workflow Helpers (Claude + Neovim + Zellij)
# ─────────────────────────────────────────────────────────────────────────────

# Start coding session: zellij + nvim + claude pane
code() {
    local dir="${1:-.}"
    local session
    
    cd "$dir" || return 1
    session=$(basename "$PWD")
    
    if [[ -n "$ZELLIJ" ]]; then
        # Already in zellij, just open the layout
        nvim .
    else
        # Start full dev environment
        zellij --session "$session" --layout dev
    fi
}

# Start Claude in the right pane (if in dev layout)
claude-pane() {
    if [[ -z "$ZELLIJ" ]]; then
        echo "Not inside Zellij. Use 'zdev' to start dev layout."
        return 1
    fi
    
    # Try to focus the claude pane and run claude
    zellij action focus-next-pane
    claude
}

# ─────────────────────────────────────────────────────────────────────────────
# Cheatsheet
# ─────────────────────────────────────────────────────────────────────────────

zj-help() {
    cat << 'EOF'
╔══════════════════════════════════════════════════════════════════════════════╗
║                    ZELLIJ CHEATSHEET (for tmux users)                        ║
╠══════════════════════════════════════════════════════════════════════════════╣
║  PREFIX: Ctrl+b (tmux default)                                               ║
╠══════════════════════════════════════════════════════════════════════════════╣
║                                                                              ║
║  SESSIONS (shell commands)                                                   ║
║  ─────────────────────────────────────────────────────────────────────────── ║
║  zj              Interactive session picker (like choose-tree)               ║
║  zs [name]       Start/attach session (tmux new -A -s)                       ║
║  zdev [name]     Start dev layout (nvim + claude pane)                       ║
║  zjls            List sessions (tmux ls)                                     ║
║  zjkill <name>   Kill session (tmux kill-session -t)                         ║
║  zjkillall       Kill all sessions (tmux kill-server)                        ║
║                                                                              ║
║  PANES (inside zellij: Ctrl+b, then...)                                      ║
║  ─────────────────────────────────────────────────────────────────────────── ║
║  |  or  v        Split vertically (right)                                    ║
║  -  or  s        Split horizontally (down)                                   ║
║  x               Close pane                                                  ║
║  z               Toggle fullscreen (zoom)                                    ║
║  f               Toggle floating pane                                        ║
║  h/j/k/l         Navigate panes (vim-style)                                  ║
║  H/J/K/L         Resize panes                                                ║
║                                                                              ║
║  TABS (inside zellij: Ctrl+b, then...)                                       ║
║  ─────────────────────────────────────────────────────────────────────────── ║
║  c               New tab (tmux: c)                                           ║
║  n / p           Next/Previous tab                                           ║
║  1-9             Go to tab by number                                         ║
║  ,               Rename tab                                                  ║
║  w               Tab picker mode                                             ║
║                                                                              ║
║  SCROLL/COPY (inside zellij: Ctrl+b, then...)                                ║
║  ─────────────────────────────────────────────────────────────────────────── ║
║  [               Enter scroll mode (like copy-mode)                          ║
║  j/k             Scroll up/down                                              ║
║  Ctrl+d/u        Half-page scroll                                            ║
║  /               Search                                                      ║
║  q               Exit scroll mode                                            ║
║                                                                              ║
║  OTHER                                                                       ║
║  ─────────────────────────────────────────────────────────────────────────── ║
║  d               Detach (tmux: d)                                            ║
║  Space           Cycle layouts                                               ║
║                                                                              ║
║  QUICK NAVIGATION (no prefix needed)                                         ║
║  ─────────────────────────────────────────────────────────────────────────── ║
║  Alt+h/j/k/l     Switch panes directly                                       ║
║                                                                              ║
╠══════════════════════════════════════════════════════════════════════════════╣
║  TMUX → ZELLIJ TRANSLATION                                                   ║
║  ─────────────────────────────────────────────────────────────────────────── ║
║  tmux new -s X        →  zs X  or  zellij -s X                               ║
║  tmux attach -t X     →  zellij attach X                                     ║
║  tmux ls              →  zjls  or  zellij ls                                 ║
║  tmux kill-session    →  zjkill X                                            ║
║  prefix %             →  prefix |  (split right)                             ║
║  prefix "             →  prefix -  (split down)                              ║
║  prefix z             →  prefix z  (zoom - same!)                            ║
║  prefix d             →  prefix d  (detach - same!)                          ║
║  prefix [             →  prefix [  (scroll - same!)                          ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝
EOF
}

# Alias for the cheatsheet
alias zhelp='zj-help'
alias zellij-help='zj-help'


