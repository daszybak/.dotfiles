# ----------------------------------------
# Homebrew environment
eval "$(/opt/homebrew/bin/brew shellenv)"

# NVM (Node Version Manager)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Go
export GOPATH="$HOME/go"
export PATH="$PATH:$(go env GOPATH)/bin"
export PATH="$PATH:$GOPATH/bin"
# Local binaries
export PATH="$HOME/.local/bin:$PATH"
