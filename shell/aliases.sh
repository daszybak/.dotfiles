# shell/aliases.sh
# Cross-platform shell aliases

# ── Navigation ───────────────────────────────────────────────────────────────
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# ── Listing ──────────────────────────────────────────────────────────────────
alias ls='ls --color=auto 2>/dev/null || ls -G'
alias ll='ls -lah'
alias la='ls -A'
alias l='ls -CF'

# ── Safety ───────────────────────────────────────────────────────────────────
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# ── Git ──────────────────────────────────────────────────────────────────────
alias g='git'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'
alias gd='git diff'
alias gco='git checkout'
alias gb='git branch'
alias glog='git log --oneline --graph --decorate'

# ── Editor ───────────────────────────────────────────────────────────────────
alias v='nvim'
alias vim='nvim'

# ── Zellij (terminal multiplexer) ────────────────────────────────────────────
# Primary commands are in zellij-helper.sh (zj, zs, zdev, zjls, etc.)
# These are fallback/quick aliases
alias zja='zellij attach'
alias zjd='zellij --layout dev'
alias zjc='zellij --layout claude'

# ── Claude Code ──────────────────────────────────────────────────────────────
alias c='claude'
alias cc='claude chat'
alias cr='claude resume'

# ── Modern CLI replacements (if installed) ──────────────────────────────────
command -v bat &>/dev/null && alias cat='bat --style=plain'
command -v eza &>/dev/null && alias ls='eza' && alias ll='eza -la' && alias tree='eza --tree'
command -v rg &>/dev/null && alias grep='rg'
command -v fd &>/dev/null && alias find='fd'
command -v delta &>/dev/null && alias diff='delta'

# ── Quick edit configs ───────────────────────────────────────────────────────
alias dotfiles='cd ~/.dotfiles && nvim'
alias zshrc='nvim ~/.zshrc'
alias bashrc='nvim ~/.bashrc'
alias vimrc='nvim ~/.config/nvim/init.lua'
alias zellijrc='nvim ~/.config/zellij/config.kdl'

