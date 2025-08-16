#!/bin/bash

# install-language-servers.sh - Interactive Language Server Installer
# Supports Linux, macOS, and WSL

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging functions
log() { echo -e "${GREEN}[+]${NC} $*"; }
warn() { echo -e "${YELLOW}[!]${NC} $*" >&2; }
error() { echo -e "${RED}[x]${NC} $*" >&2; exit 1; }
info() { echo -e "${BLUE}[i]${NC} $*"; }

# Detect platform
detect_platform() {
    case "$(uname -s)" in
        Linux*) 
            if [[ -n "${WSL_DISTRO_NAME:-}" ]] || grep -qi microsoft /proc/version 2>/dev/null; then
                PLATFORM="wsl"
            else
                PLATFORM="linux"
            fi
            ;;
        Darwin*) PLATFORM="macos";;
        *) PLATFORM="unknown";;
    esac
    log "Platform detected: $PLATFORM"
}

# Check for package managers
check_package_managers() {
    case "$PLATFORM" in
        macos)
            if ! command -v brew &> /dev/null; then
                warn "Homebrew not found. Installing..."
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            fi
            PKG_MANAGER="brew"
            ;;
        linux|wsl)
            if command -v apt &> /dev/null; then
                PKG_MANAGER="apt"
            elif command -v yum &> /dev/null; then
                PKG_MANAGER="yum"
            elif command -v pacman &> /dev/null; then
                PKG_MANAGER="pacman"
            elif command -v zypper &> /dev/null; then
                PKG_MANAGER="zypper"
            else
                error "No supported package manager found"
            fi
            ;;
        *)
            error "Unsupported platform: $PLATFORM"
            ;;
    esac
    log "Package manager: $PKG_MANAGER"
}

# Install Node.js if not present (needed for many language servers)
ensure_nodejs() {
    if ! command -v node &> /dev/null; then
        info "Node.js not found, installing..."
        case "$PKG_MANAGER" in
            brew) brew install node;;
            apt) sudo apt update && sudo apt install -y nodejs npm;;
            yum) sudo yum install -y nodejs npm;;
            pacman) sudo pacman -S nodejs npm;;
            zypper) sudo zypper install nodejs npm;;
        esac
    fi
}

# Install Rust if not present (needed for rust-analyzer)
ensure_rust() {
    if ! command -v rustc &> /dev/null; then
        info "Rust not found, installing via rustup..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        source "$HOME/.cargo/env"
    fi
}

# Install Go if not present (needed for gopls)
ensure_go() {
    if ! command -v go &> /dev/null; then
        info "Go not found, installing..."
        case "$PKG_MANAGER" in
            brew) brew install go;;
            apt) sudo apt update && sudo apt install -y golang-go;;
            yum) sudo yum install -y golang;;
            pacman) sudo pacman -S go;;
            zypper) sudo zypper install go;;
        esac
    fi
}

# Language server installation functions
install_clangd() {
    log "Installing clangd (C/C++ Language Server)..."
    case "$PKG_MANAGER" in
        brew) brew install llvm;;
        apt) sudo apt update && sudo apt install -y clangd;;
        yum) sudo yum install -y clang-tools-extra;;
        pacman) sudo pacman -S clang;;
        zypper) sudo zypper install clang;;
    esac
}

install_pyright() {
    log "Installing pyright (Python Language Server)..."
    ensure_nodejs
    npm install -g pyright
}

install_pylsp() {
    log "Installing python-lsp-server (Alternative Python Language Server)..."
    if command -v pip3 &> /dev/null; then
        pip3 install --user python-lsp-server[all]
    elif command -v pip &> /dev/null; then
        pip install --user python-lsp-server[all]
    else
        warn "pip not found, installing python3-pip..."
        case "$PKG_MANAGER" in
            brew) brew install python3;;
            apt) sudo apt update && sudo apt install -y python3-pip;;
            yum) sudo yum install -y python3-pip;;
            pacman) sudo pacman -S python-pip;;
            zypper) sudo zypper install python3-pip;;
        esac
        pip3 install --user python-lsp-server[all]
    fi
}

install_typescript_language_server() {
    log "Installing typescript-language-server..."
    ensure_nodejs
    npm install -g typescript-language-server typescript
}

install_rust_analyzer() {
    log "Installing rust-analyzer (Rust Language Server)..."
    ensure_rust
    rustup component add rust-analyzer
}

install_gopls() {
    log "Installing gopls (Go Language Server)..."
    ensure_go
    go install golang.org/x/tools/gopls@latest
}

install_lua_language_server() {
    log "Installing lua-language-server..."
    case "$PKG_MANAGER" in
        brew) brew install lua-language-server;;
        apt) 
            # Build from source for apt systems
            warn "Building lua-language-server from source..."
            cd /tmp
            git clone https://github.com/LuaLS/lua-language-server.git
            cd lua-language-server
            ./make.sh
            sudo cp -r bin /opt/lua-language-server
            sudo ln -sf /opt/lua-language-server/lua-language-server /usr/local/bin/
            ;;
        pacman) 
            if pacman -Si lua-language-server &> /dev/null; then
                sudo pacman -S lua-language-server
            else
                warn "lua-language-server not in repos, install from AUR"
            fi
            ;;
        *) warn "Manual installation required for lua-language-server on this system";;
    esac
}

install_bash_language_server() {
    log "Installing bash-language-server..."
    ensure_nodejs
    npm install -g bash-language-server
}

install_yaml_language_server() {
    log "Installing yaml-language-server..."
    ensure_nodejs
    npm install -g yaml-language-server
}

install_json_language_server() {
    log "Installing vscode-json-languageserver..."
    ensure_nodejs
    npm install -g vscode-langservers-extracted
}

# Interactive menu
show_menu() {
    echo ""
    info "=== Language Server Installer ==="
    echo "Select language servers to install (space-separated numbers, or 'all'):"
    echo ""
    echo "  1) clangd (C/C++)"
    echo "  2) pyright (Python - Microsoft)"
    echo "  3) pylsp (Python - Community)"
    echo "  4) typescript-language-server (TypeScript/JavaScript)"
    echo "  5) rust-analyzer (Rust)"
    echo "  6) gopls (Go)"
    echo "  7) lua-language-server (Lua)"
    echo "  8) bash-language-server (Bash)"
    echo "  9) yaml-language-server (YAML)"
    echo " 10) json-language-server (JSON)"
    echo ""
    echo "  0) Show recommended modern tools"
    echo ""
}

show_modern_tools() {
    echo ""
    info "=== Recommended Modern Tools ==="
    echo ""
    echo "For a more modern approach, consider these excellent tools:"
    echo ""
    echo "1. ASDF Version Manager (https://asdf-vm.com/)"
    echo "   - Manages multiple language runtimes and tools"
    echo "   - Cross-platform support"
    echo "   - Plugin ecosystem for language servers"
    echo "   Install: curl -fsSL https://asdf-vm.com/install.sh | bash"
    echo ""
    echo "2. Mason.nvim (if using Neovim)"
    echo "   - Portable package manager for Neovim"
    echo "   - Installs and manages LSP servers, DAP servers, linters, formatters"
    echo "   - Built-in UI for easy management"
    echo ""
    echo "3. Language-specific managers:"
    echo "   - rustup (Rust toolchain)"
    echo "   - nvm/fnm (Node.js versions)"
    echo "   - pyenv (Python versions)"
    echo "   - gvm (Go versions)"
    echo ""
    echo "4. Universal Package Managers:"
    echo "   - mise (https://mise.jdx.dev/) - Modern replacement for asdf"
    echo "   - proto (https://moonrepo.dev/proto) - Unified toolchain manager"
    echo ""
    read -p "Press Enter to return to main menu..."
}

# Main function
main() {
    log "Starting Language Server Installer"
    detect_platform
    check_package_managers
    
    while true; do
        show_menu
        read -p "Enter your choice(s): " -a choices
        
        if [[ "${choices[0]}" == "0" ]]; then
            show_modern_tools
            continue
        fi
        
        if [[ "${choices[0]}" == "all" ]]; then
            choices=(1 2 4 5 6 7 8 9 10)  # Skip pylsp (3) when installing all
        fi
        
        for choice in "${choices[@]}"; do
            case "$choice" in
                1) install_clangd;;
                2) install_pyright;;
                3) install_pylsp;;
                4) install_typescript_language_server;;
                5) install_rust_analyzer;;
                6) install_gopls;;
                7) install_lua_language_server;;
                8) install_bash_language_server;;
                9) install_yaml_language_server;;
                10) install_json_language_server;;
                *) warn "Invalid choice: $choice";;
            esac
        done
        
        log "Installation complete!"
        echo ""
        info "Language servers installed. Make sure your editor is configured to use them."
        info "Common paths to add to PATH:"
        echo "  - ~/.cargo/bin (Rust tools)"
        echo "  - ~/go/bin (Go tools)"
        echo "  - ~/.local/bin (Python tools)"
        echo ""
        read -p "Install more language servers? (y/N): " response
        case "${response,,}" in
            y|yes) continue;;
            *) break;;
        esac
    done
    
    log "Language server setup complete!"
}

# Show usage if help requested
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    echo "Usage: $0 [OPTIONS]"
    echo "Interactive language server installer for multiple platforms"
    echo ""
    echo "OPTIONS:"
    echo "    -h, --help     Show this help message"
    echo ""
    echo "This script will:"
    echo "  - Detect your platform (Linux/macOS/WSL)"
    echo "  - Install required dependencies"
    echo "  - Provide interactive selection of language servers"
    echo "  - Recommend modern alternative tools"
    exit 0
fi

# Run main function
main
