# ----------------------------------------
# Homebrew environment
eval "$(/opt/homebrew/bin/brew shellenv)"

# Python paths
export PATH="$HOME/Library/Python/3.9/lib/python/site-packages:$HOME/Library/Python/3.11/bin:$PATH"

# NVM (Node Version Manager)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Go
export GOPATH="$HOME/go"
export PATH="$PATH:$(go env GOPATH)/bin"
export PATH="$PATH:$GOPATH/bin"

# Android SDK
export ANDROID_HOME="$HOME/Library/Android/sdk"
export PATH="$PATH:$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools"

# Local binaries
export PATH="$HOME/.local/bin:$PATH"

# LunarVim
export PATH="/path/to/lvim:$PATH"

# JVM memory options
export _JAVA_OPTIONS="-Xms256m -Xmx2g"

# Custom C++ helper
cprun() {
    g++ -std=c++17 -O2 -o out "$1" && ./out
}

_MY_VMOPTIONS_SHELL_FILE="${HOME}/.jetbrains.vmoptions.sh"
[ -f "${___MY_VMOPTIONS_SHELL_FILE}" ] && . "${___MY_VMOPTIONS_SHELL_FILE}"
