??? from here until ???END lines may have been inserted/deleted

# 🛠️ daszybak's Dotfiles

Minimal, cross-platform dotfiles for **macOS**, **Linux**, and **WSL2**.  
Designed to bootstrap a consistent shell environment with **native tools only** and no global dependencies.

Includes:

- 🐚 Shell support: Bash + Zsh
- 🧩 Modular config loading: `~/.config/shell/`
- ✏️ Vim + Neovim with sensible defaults
- 🖥️ Tmux config with clipboard support (macOS, WSL)
- 🧬 Smart deployment: `stow` or native symlinks
- 🔐 Native GPG-based encryption for secrets like `.ssh/config.local`
- ⚡ Auto-sourcing of shell configs on completion
- 🔧 Interactive language server installer for development

---

## 📥 Installation

### 🔹 Interactive setup

```bash
curl -fsSL https://raw.githubusercontent.com/daszybak/.dotfiles/main/install.sh | bash
```

### 🔹 Auto-confirm / CI-friendly setup

```bash
curl -fsSL https://raw.githubusercontent.com/daszybak/.dotfiles/main/install.sh | bash -s -- -y
```

### 🔹 Manual clone & run

```bash
git clone git@github.com:daszybak/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh -y
```

## Folder Structure

```text
.dotfiles/
├── install.sh             # Cross-platform setup script
├── scripts/
│   └── install-language-servers.sh  # Interactive LSP installer
├── bash/.bashrc           # Bash config
├── zsh/.zshrc             # Zsh config
├── vim/.vimrc             # Lean Vim setup
├── nvim/                  # Neovim configuration
├── tmux/.tmux.conf        # Tmux with platform-specific clipboard
├── zellij/                # Zellij terminal multiplexer config
│   └── layouts/dev.kdl    # Dev layout (nvim + Claude Code)
└── shell/
    ├── core.sh
    ├── aliases.sh
    ├── exports.sh
    ├── functions.sh
    └── platforms/
        ├── linux.sh
        ├── macos.sh
        ├── windows.sh
        └── wsl.sh
```

## 🛣️ Roadmap

### ✅ Completed

- [x] Modular shell setup using `~/.config/shell/`
- [x] Platform-specific overrides using `uname` and auto-detection
- [x] Smart deployment: `stow` or native symlinks with user choice
- [x] Backup of existing dotfiles before overwriting
- [x] GPG-based encryption for sensitive dotfiles
- [x] `.ssh/config.local` decryption on install if present
- [x] Auto-sourcing of shell configurations on completion
- [x] Interactive language server installer for development
- [x] Cleaned up window managers (removed yabai, skhd, aerospace)
- [x] Fixed GitHub Actions workflow

### 🧩 Language Server Support

The interactive language server installer (`scripts/install-language-servers.sh`) supports:

- **C/C++**: clangd
- **Python**: pyright (Microsoft) or pylsp (community)
- **TypeScript/JavaScript**: typescript-language-server
- **Rust**: rust-analyzer
- **Go**: gopls
- **Lua**: lua-language-server
- **Bash**: bash-language-server
- **YAML/JSON**: yaml-language-server, json-language-server

Also recommends modern alternatives like:

- [asdf](https://asdf-vm.com/) - Universal version manager
- [mise](https://mise.jdx.dev/) - Modern replacement for asdf
- [Mason.nvim](https://github.com/williamboman/mason.nvim) - For Neovim users

### 🧩 Planned Improvements

- [ ] Add support for `.bashrc.local` / `.zshrc.local` overrides
- [ ] Integrate Git credential helper config (`~/.git-credentials`)
- [ ] Optional remote provisioning (e.g., via SSH or cloud-init)
- [ ] Add support for restoring configs like:
  - [ ] `~/.gnupg`
  - [ ] `~/.netrc`
  - [ ] `~/.aws/config`
  - [ ] `~/.docker/config.json`

## 💡 Philosophy

- 📦 No global dependencies — native tools only
- 💥 Safe to run repeatedly
- 🧽 Reversible, debuggable, and modular
- ✨ Keep the setup minimal but extensible

📎 License
MIT — use freely, customize as needed.
