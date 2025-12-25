# Claude Code Project Instructions

## Project Context

This is a dotfiles repository for cross-platform (macOS/Linux) development environment configuration.

## Coding Standards

- Use POSIX-compliant shell scripts when possible
- Prefer explicit over implicit behavior
- Document non-obvious decisions
- Follow existing code style in the codebase

## File Organization

- `nvim/` - Neovim configuration (Lua-based, uses lazy.nvim)
- `zellij/` - Zellij terminal multiplexer config
- `shell/` - Modular shell configuration
- `bash/`, `zsh/` - Shell-specific configs
- `scripts/` - Utility scripts

## Neovim Guidelines

- Plugins should be lazy-loaded when possible
- Avoid using `any` type in Lua code
- Use outline rounded icon variants for UI components

## Shell Script Guidelines

- Scripts must work on both macOS and Linux
- Use `#!/usr/bin/env bash` shebang
- Always use `set -euo pipefail`
- Prefer functions over inline code
- Use clear, descriptive variable names

