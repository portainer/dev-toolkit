# alapenna-nixos toolkit

A NixOS-based development environment for Portainer development. This is the declarative, VM-based alternative to the alapenna-ghostty container toolkit.

## Quick Start

### Prerequisites

- macOS with OrbStack installed
- `~/.local/bin` in your PATH

### Installation

```bash
# 1. Copy the devbox-nix script to your PATH
cp devbox-nix ~/.local/bin/
chmod +x ~/.local/bin/devbox-nix

# 2. Enter the VM (creates it on first run)
devbox-nix

# This will:
# - Create a NixOS VM named "devbox-nix"
# - Apply the configuration.nix
# - Drop you into a zsh shell
```

### First Time Setup (Manual - Requires Auth)

All tools are installed automatically. These steps require interactive authentication:

```bash
# Git configuration
git config --global user.email <email>
git config --global user.name <name>

# GitHub CLI
gh auth login

# Claude Code (already installed, just authenticate)
claude
```

## Daily Workflow

```bash
# Enter the VM
devbox-nix

# You're now in NixOS. Work as usual.
# Multiple terminals can connect to the same VM.

# Exit with Ctrl+D or 'exit'
# VM keeps running in the background
```

## Commands

| Command | Description |
|---------|-------------|
| `devbox-nix` | Enter VM (creates/starts if needed) |
| `devbox-nix stop` | Stop the VM |
| `devbox-nix destroy` | Remove VM completely |
| `devbox-nix status` | Show VM status and generations |
| `devbox-nix rebuild` | Apply configuration.nix changes |
| `devbox-nix rollback` | Rollback to previous generation |

## Making Changes

### The NixOS Way

Instead of installing packages imperatively, edit `configuration.nix`:

```nix
# Add a package
environment.systemPackages = with pkgs; [
  # ... existing packages ...
  httpie  # <- add here
];
```

Then apply:

```bash
devbox-nix rebuild
```

The change is now:
- Applied to your system
- Recorded as a new generation (rollback available)
- In git (commit configuration.nix)

### Rollback

Something broke? Instant recovery:

```bash
devbox-nix rollback
```

Or pick a specific generation:

```bash
# Inside the VM
sudo nix-env --list-generations -p /nix/var/nix/profiles/system
sudo nixos-rebuild switch --generation <number>
```

## File Sharing

OrbStack automatically shares your macOS filesystem:

```bash
# Inside the VM, your macOS home is accessible
ls /Users/<your-username>/

# Common pattern: symlink your workspace
ln -s /Users/<your-username>/workspaces ~/workspaces
```

For better organization, you might want specific mounts. Edit your configuration to add bind mounts or use OrbStack's volume features.

## Adding X11 + Chrome (Later)

When you're ready for browser integration:

1. Uncomment the X11 section in `configuration.nix`
2. Run `devbox-nix rebuild`
3. Install XQuartz on macOS: `brew install --cask xquartz`
4. Connect with X11 forwarding: `ssh -X devbox-nix@orb`
5. Run `google-chrome-stable`

The Chrome window will appear on your Mac, but the process runs in the sandboxed VM.

## Differences from Container Toolkit

| Aspect | Container | NixOS VM |
|--------|-----------|----------|
| Enter | `devbox-nix` (same) | `devbox-nix` (same) |
| Add package | `apt install X` | Edit config, `devbox-nix rebuild` |
| Undo change | Not possible | `devbox-nix rollback` |
| View history | N/A | `devbox-nix status` |
| Docker | Uses host socket | Native Docker in VM |
| SSH keys | Mounted from host | Copy or mount |

## Included Tools

Same tools as alapenna-ghostty:

- **Languages**: Go, Node.js 22, Yarn
- **Go tools**: golangci-lint, gopls
- **Git**: lazygit, delta, gh
- **Terminal**: zsh, starship, fzf, ripgrep, fd, bat, eza
- **Files**: yazi, zoxide, glow
- **Editor**: fresh
- **AI**: Claude Code
- **Scripts**: ccm (Claude commit message generator)

Most packages come from the stable NixOS channel. `claude-code` and `fresh-editor` are pulled from nixpkgs-unstable.

## Customization

### Adding Your Own Packages

```nix
environment.systemPackages = with pkgs; [
  # Search for packages: https://search.nixos.org/packages
  your-package-here

  # For packages only in unstable:
  unstable.some-new-package
];
```

### Shell Aliases

Edit the `programs.zsh.shellAliases` section:

```nix
programs.zsh.shellAliases = {
  lg = "lazygit";
  # Add your aliases here
};
```

### Environment Variables

```nix
environment.variables = {
  MY_VAR = "value";
};
```

## Troubleshooting

### VM won't start

```bash
# Check OrbStack status
orb list

# Try stopping and starting
devbox-nix stop
devbox-nix
```

### Configuration error

```bash
# Check syntax
nix-instantiate --parse configuration.nix

# If rebuild failed, rollback
devbox-nix rollback
```

### Package not found

Search for the correct package name:
- https://search.nixos.org/packages
- Or: `nix search nixpkgs <name>`

## Migration from Container

1. Export any data from `/workspace` in your container
2. Set up the NixOS VM with `devbox-nix`
3. Clone your repos into the VM (or access via /Users mount)
4. Re-authenticate git, gh, claude

Your workflow stays the same - just the underlying infrastructure is declarative now.

## References

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [NixOS Package Search](https://search.nixos.org/packages)
- [Home Manager](https://github.com/nix-community/home-manager) - For user-level declarative config
- [OrbStack Docs](https://docs.orbstack.dev/machines/)
