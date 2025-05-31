# bash/.bashrc
# Cross-platform bash configuration

# Platform detection
export PLATFORM=$(uname -s | tr '[:upper:]' '[:lower:]')
[[ -n "${WSL_DISTRO_NAME:-}" ]] && export PLATFORM="wsl"

# Load modular configs
for config in ~/.config/shell/{core,aliases,functions,exports}.sh; do
    [[ -r "$config" ]] && source "$config"
done

# Platform-specific overrides
[[ -r ~/.config/shell/platforms/${PLATFORM}.sh ]] && source ~/.config/shell/platforms/${PLATFORM}.sh

# Local overrides
[[ -r ~/.bashrc.local ]] && source ~/.bashrc.local

