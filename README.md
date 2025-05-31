??? from here until ???END lines may have been inserted/deleted
# 🛠️ daszybak's Dotfiles

Minimal, cross-platform dotfiles for **macOS**, **Linux**, and **WSL2**.  
Designed to bootstrap a consistent shell environment with **native tools only** and no global dependencies.

Includes:

- 🐚 Shell support: Bash + Zsh
- 🧩 Modular config loading: `~/.config/shell/`
- ✏️ Vim with sensible defaults
- 🖥️ Tmux config with clipboard support (macOS, WSL)
- 🧬 Optional `stow`-based layout (skipped in `--yes` mode)
- 🔐 Native GPG-based encryption for secrets like `.ssh/config.local`

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
├── bash/.bashrc           # Bash config
├── zsh/.zshrc             # Zsh config
├── vim/.vimrc             # Lean Vim setup
├── tmux/.tmux.conf        # Tmux with platform-specific clipboard
├── shell/
│   ├── core.sh
│   ├── aliases.sh
│   ├── exports.sh
│   ├── functions.sh
│   └── platforms/
│       ├── linux.sh
│       ├── macos.sh
│       ├── windows.sh
│       └── wsl.sh
└── secrets/               # GPG-encrypted files (e.g. .ssh/config.local)
```

## 🛣️ Roadmap

### ✅ Completed

- [x] Modular shell setup using `~/.config/shell/`
- [x] Platform-specific overrides using `uname` and auto-detection
- [x] Manual symlink fallback (avoids requiring `stow` in `--yes` mode)
- [x] Backup of existing dotfiles before overwriting
- [x] GPG-based encryption for sensitive dotfiles
- [x] `.ssh/config.local` decryption on install if present

### 🧩 Planned Improvements

- [ ] Add support for `.bashrc.local` / `.zshrc.local` overrides
- [ ] Integrate Git credential helper config (`~/.git-credentials`)
- [ ] Add Makefile targets:
  - [ ] `make decrypt` – decrypt secrets
  - [ ] `make encrypt` – encrypt secrets
  - [ ] `make bootstrap` – end-to-end system setup
  - [ ] `make clean` – remove symlinks and backups
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

