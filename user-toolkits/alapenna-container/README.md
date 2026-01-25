# alapenna-container toolkit

A development environment using Apple's native container CLI on macOS 26+.

## Prerequisites

- macOS 26 (Tahoe) or later
- Apple Silicon Mac
- zsh shell (default on macOS)

## Installing Apple Container CLI

Follow the official installation guide: [apple/container - Install or Upgrade](https://github.com/apple/container?tab=readme-ov-file#install-or-upgrade)

Verify installation:

```bash
container --version
container system status
```

## Isolation Benefits

Unlike OrbStack which [auto-mounts /Users and /Volumes](https://github.com/orbstack/orbstack/issues/169), Apple container only mounts what you explicitly configure. Each container runs in its own lightweight VM, providing true isolation without shared attack surfaces. This makes it suitable for running untrusted code (like AI agents) in a sandboxed environment.

## Install devbox-apple script

**Note:** The `devbox-apple` script requires `zsh` (default shell on macOS).

```bash
cd user-toolkits/alapenna-container
cp devbox-apple ~/.local/bin/
chmod +x ~/.local/bin/devbox-apple
```

## Quick Start

```bash
# 1. Build the image
devbox-apple build

# 2. Start and enter the container
devbox-apple

# 3. You're in! Multiple terminals can connect
```

## Commands

| Command | Description |
|---------|-------------|
| `devbox-apple` | Enter container (creates if needed) |
| `devbox-apple stop` | Stop the container |
| `devbox-apple destroy` | Remove the container |
| `devbox-apple status` | Show container/image status |
| `devbox-apple build` | Build the image from Dockerfile |
| `devbox-apple build --keep-builder` | Build and keep builder running (faster rebuilds) |
| `devbox-apple rebuild` | Destroy container and rebuild image |
| `devbox-apple rebuild --keep-builder` | Rebuild and keep builder running |
| `devbox-apple builder-configure [profile]` | Configure builder with preset profile (light/balanced/performance/max) |
| `devbox-apple logs` | Show container logs |

## Directory Configuration

### Volume Mounts (Live-Synced)

| Host | Container | Access |
|------|-----------|--------|
| `~/workspaces/toolkit-workspace` | `/workspace` | read-write |
| `~/tmp/dev-toolkit` | `/share-tmp` | read-write |

These directories are mounted and changes sync immediately between host and container.

### Copied Directories (One-Time)

| Host | Container | When |
|------|-----------|------|
| `~/.ssh` | `/root/.ssh` | On first container creation |
| `~/.gnupg` | `/root/.gnupg` | On first container creation |

SSH and GPG credentials are copied into the container once during initial setup. Changes made inside the container won't affect your host credentials, and vice versa.

**Note:** Edit the `devbox-apple` script to customize paths.

## First Time Setup

On first container creation, setup runs automatically in this order:

### 1. Automatic Configuration (No Interaction)

**Git Identity & Signing:**
- `user.email` - copied from host
- `user.name` - copied from host
- `user.signingkey` - copied from host (if configured)
- `commit.gpgsign` - enabled if signing key exists
- `push.autoSetupRemote` - enabled automatically

**Credentials:**
- SSH keys from `~/.ssh` - copied to container
- GPG keys from `~/.gnupg` - copied to container

**Requirements on Host Mac:**

Ensure your host Mac has git configured before creating the container:

```bash
# Verify your host git config
git config --global user.email
git config --global user.name
git config --global user.signingkey

# If missing, configure on your Mac:
git config --global user.email "you@example.com"
git config --global user.name "Your Name"
git config --global user.signingkey <GPG_KEY_ID>
```

### 2. GitHub CLI Authentication (Browser-Based)

After copying credentials, GitHub CLI authentication starts automatically:
- Browser opens on your Mac to https://github.com/login/device
- A one-time code is displayed in the terminal
- Enter the code in your browser to authorize
- Authentication persists across container restarts

Settings applied automatically:
- Git protocol: SSH
- SSH key upload: Skipped (keys already copied from host)

### 3. Claude Code Authentication (First Use)

Authenticate Claude Code the first time you run it:

```bash
claude
# Follow the authentication prompts
```

Authentication persists across container restarts.

## Included Tools

- **Languages**: Go, Node.js, Yarn (from base image)
- **Git**: lazygit, delta, gh
- **Terminal**: zsh, starship, fzf, ripgrep, fd, bat, eza
- **Files**: yazi, zoxide, glow
- **Editor**: fresh
- **AI**: Claude Code with plugins (claude-hud, plannotator)
- **Scripts**: ccm (Claude commit message generator)

## Builder Configuration

### How the Builder Works

The build process uses a **separate builder VM** (managed by Apple container). This builder:

1. **Auto-creates on first build** using script defaults (8 CPUs / 8g by default)
2. **Auto-removes after each build** to free resources immediately
3. **Recreates on next build** (~10-30 seconds overhead)

**This design maximizes resources for your working container** - the builder only consumes RAM/CPU during builds.

### Builder Resource Profiles

The **recommended profile is `performance`** (8 CPUs / 8g) for optimal build speed. If needed, you can adjust based on your Mac's capabilities:

```bash
# Recommended (default if no profile specified)
devbox-apple builder-configure performance  # 8 CPUs / 8g   - Fast builds (recommended)

# Alternative profiles
devbox-apple builder-configure light        # 2 CPUs / 2g   - Minimal (16GB Mac)
devbox-apple builder-configure balanced     # 4 CPUs / 4g   - Good balance
devbox-apple builder-configure max          # 12 CPUs / 16g - Maximum (64GB Mac)
```

**Profile persists** across builds until you change it or until auto-removal happens.

### Keeping Builder Between Builds

During active Dockerfile development (frequent rebuilds), keep the builder to avoid recreation overhead:

```bash
devbox-apple rebuild --keep-builder  # Builder stays after build
devbox-apple rebuild --keep-builder  # Reuses existing builder (fast!)
devbox-apple rebuild                 # Final build removes builder
```

## Port Configuration

The container exposes ports **10000-19999** (mapped 1:1 to host) to avoid conflicts with system services.

### Pre-configured Services

| Port | Service |
|------|---------|
| 17777 | Plannotator |

## Known Limitations

- **No snapshots yet**: The `container` CLI doesn't expose VM snapshot/restore (though Virtualization.framework supports it)
- **Pre-1.0**: API may change between versions
- **Image unpacking**: Can be slow for large images
- **No Docker socket mounting (yet)**: Single file/socket mounting [was merged](https://github.com/apple/containerization/pull/487) on 2026-01-23 but not yet released (current: 0.8.0). Expected in a future release. Until then, use Docker CLI from your host Mac instead of inside the container

## Future Enhancements

Coming in next container CLI release:
- Docker socket mounting (merged, awaiting release - see Known Limitations)

Potential wrapper features to build:
- Snapshot/restore via Swift (using Virtualization.framework APIs)
- Multiple named containers
- Container profiles (different resource allocations)

## Troubleshooting

### Container won't start

```bash
# Check system status
container system status

# View logs
container system logs
```

## References

- [apple/container](https://github.com/apple/container) - CLI tool
- [apple/containerization](https://github.com/apple/containerization) - Swift framework
- [Virtualization.framework](https://developer.apple.com/documentation/virtualization) - Apple docs
