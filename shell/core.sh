# shell/core.sh
# Core shell configuration (loaded first)

# ── Shell options ────────────────────────────────────────────────────────────
# Bash-specific options (won't error in zsh)
if [[ -n "${BASH_VERSION:-}" ]]; then
    shopt -s histappend      # Append to history file
    shopt -s checkwinsize    # Update LINES and COLUMNS
    shopt -s cdspell         # Autocorrect cd typos
    shopt -s dirspell        # Autocorrect directory typos
    shopt -s globstar        # Enable ** for recursive globbing
    shopt -s nocaseglob      # Case-insensitive globbing
    shopt -s autocd          # cd into directory by typing its name
fi

# ── Prompt ───────────────────────────────────────────────────────────────────
# Simple, informative prompt
# Shows: user@host:directory (git-branch)$

__git_branch() {
    git branch 2>/dev/null | grep '^\*' | sed 's/^\* //'
}

__prompt_command() {
    local exit_code=$?
    local git_branch
    git_branch=$(__git_branch)

    # Colors
    local reset='\[\033[0m\]'
    local red='\[\033[0;31m\]'
    local green='\[\033[0;32m\]'
    local blue='\[\033[0;34m\]'
    local cyan='\[\033[0;36m\]'
    local yellow='\[\033[0;33m\]'

    # User/host - green for regular user, red for root
    local user_color="$green"
    [[ $EUID -eq 0 ]] && user_color="$red"

    # Directory
    local dir="$blue\w$reset"

    # Git branch
    local git=""
    [[ -n "$git_branch" ]] && git=" $yellow($git_branch)$reset"

    # Prompt symbol - red if last command failed
    local symbol="$green\$$reset"
    [[ $exit_code -ne 0 ]] && symbol="$red\$$reset"

    PS1="${user_color}\u@\h${reset}:${dir}${git} ${symbol} "
}

# Only set prompt for bash (zsh uses its own prompt system)
if [[ -n "${BASH_VERSION:-}" ]]; then
    PROMPT_COMMAND=__prompt_command
fi

# ── Completion ───────────────────────────────────────────────────────────────
# Load bash completion
if [[ -n "${BASH_VERSION:-}" ]]; then
    if [[ -r /usr/share/bash-completion/bash_completion ]]; then
        source /usr/share/bash-completion/bash_completion
    elif [[ -r /etc/bash_completion ]]; then
        source /etc/bash_completion
    elif [[ -r /opt/homebrew/etc/profile.d/bash_completion.sh ]]; then
        source /opt/homebrew/etc/profile.d/bash_completion.sh
    fi
fi

# ── Zellij auto-attach (optional) ────────────────────────────────────────────
# Uncomment to automatically attach to zellij on shell start
# if [[ -z "$ZELLIJ" ]] && command -v zellij &>/dev/null; then
#     if [[ "$ZELLIJ_AUTO_ATTACH" == "true" ]]; then
#         zellij attach -c
#     fi
# fi

