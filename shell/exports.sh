# shell/exports.sh
# Cross-platform environment variables

# ── Editor ───────────────────────────────────────────────────────────────────
export EDITOR='nvim'
export VISUAL='nvim'

# ── Pager ────────────────────────────────────────────────────────────────────
export PAGER='less'
export LESS='-R --mouse --wheel-lines=3'

# ── History ──────────────────────────────────────────────────────────────────
export HISTSIZE=50000
export HISTFILESIZE=50000
export HISTCONTROL=ignoreboth:erasedups

# ── Language ─────────────────────────────────────────────────────────────────
export LANG='en_US.UTF-8'
export LC_ALL='en_US.UTF-8'

# ── XDG Base Directory ───────────────────────────────────────────────────────
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

# ── Path additions ───────────────────────────────────────────────────────────
# Homebrew (macOS)
[[ -d /opt/homebrew/bin ]] && export PATH="/opt/homebrew/bin:$PATH"

# User binaries
[[ -d "$HOME/.local/bin" ]] && export PATH="$HOME/.local/bin:$PATH"
[[ -d "$HOME/bin" ]] && export PATH="$HOME/bin:$PATH"

# Go
[[ -d "$HOME/go/bin" ]] && export PATH="$HOME/go/bin:$PATH"

# Rust/Cargo
[[ -d "$HOME/.cargo/bin" ]] && export PATH="$HOME/.cargo/bin:$PATH"

# Node (fnm/nvm)
[[ -d "$HOME/.fnm" ]] && export PATH="$HOME/.fnm:$PATH"

# ── Claude Code ──────────────────────────────────────────────────────────────
# Set your API key in ~/.bashrc.local or ~/.zshrc.local:
# export ANTHROPIC_API_KEY="your-key-here"

# ── FZF ──────────────────────────────────────────────────────────────────────
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
if command -v fd &>/dev/null; then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
fi

# ── Ripgrep ──────────────────────────────────────────────────────────────────
if [[ -f "$HOME/.config/ripgrep/config" ]]; then
    export RIPGREP_CONFIG_PATH="$HOME/.config/ripgrep/config"
else
    unset RIPGREP_CONFIG_PATH 2>/dev/null
fi

# ── Terminal ─────────────────────────────────────────────────────────────────
export TERM="${TERM:-xterm-256color}"

# ── Zellij ───────────────────────────────────────────────────────────────────
# Auto-attach to existing session or create new one
# Uncomment to enable:
# export ZELLIJ_AUTO_ATTACH=true
# export ZELLIJ_AUTO_EXIT=true

