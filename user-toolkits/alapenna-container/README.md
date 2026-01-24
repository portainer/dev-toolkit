# alapenna-container toolkit

A development environment using Apple's native container CLI on macOS 26+.

## Why Apple Container?

| Feature | Docker/OrbStack | Apple Container |
|---------|-----------------|-----------------|
| Architecture | Shared Linux VM | VM-per-container |
| Isolation | Shared kernel | Full VM isolation |
| Host mounts | OrbStack auto-mounts /Users | Explicit only |
| Startup | ~2 sec | ~0.7 sec |
| Maintained by | Docker Inc / OrbStack | Apple |

Each container runs in its own lightweight VM, providing true isolation without shared attack surfaces.

## Prerequisites

- macOS 26 (Tahoe) or later
- Apple Silicon Mac

## Installing Apple Container CLI

Follow the official installation guide: [apple/container - Install or Upgrade](https://github.com/apple/container?tab=readme-ov-file#install-or-upgrade)

Verify installation:

```bash
container --version
container system status
```

## Install devbox-apple script

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
| `devbox-apple logs` | Show container logs |

## Directory Mounts

| Host | Container | Mode |
|------|-----------|------|
| `~/workspaces/toolkit-workspace` | `/workspace` | read-write |
| `~/.ssh` | `/root/.ssh` | copied |
| `~/.gnupg` | `/root/.gnupg` | copied |
| `~/tmp/dev-toolkit` | `/share-tmp` | read-write |

Note: SSH and GPG directories are copied into the container on first creation, not live-mounted from the host.

Edit `devbox-apple` script to customize mount paths.

## Included Tools

- **Languages**: Go, Node.js, Yarn (from base image)
- **Git**: lazygit, delta, gh
- **Terminal**: zsh, starship, fzf, ripgrep, fd, bat, eza
- **Files**: yazi, zoxide, glow
- **Editor**: fresh
- **AI**: Claude Code with plugins (claude-hud, plannotator)
- **Scripts**: ccm (Claude commit message generator)

## Port Forwarding

| Port | Service |
|------|---------|
| 6443 | Kubernetes API |
| 8999 | Plannotator |
| 9000 | Portainer HTTP |
| 9443 | Portainer HTTPS |

## Isolation Benefits

Unlike OrbStack which [auto-mounts /Users and /Volumes](https://github.com/orbstack/orbstack/issues/169), Apple container only mounts what you explicitly configure. This makes it suitable for running untrusted code (like AI agents) in a sandboxed environment.

## Known Limitations

- **No snapshots yet**: The `container` CLI doesn't expose VM snapshot/restore (though Virtualization.framework supports it)
- **Pre-1.0**: API may change between versions
- **Image unpacking**: Can be slow for large images

## Future Enhancements

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

### Image not found

```bash
# Build locally
devbox-apple build

# Or pull from registry (if published)
container image pull your-registry/devbox:latest
```

### Permission errors on mounts

Ensure the mount source directories exist and are readable:

```bash
mkdir -p ~/workspaces/toolkit-workspace ~/tmp/dev-toolkit
```

## References

- [apple/container](https://github.com/apple/container) - CLI tool
- [apple/containerization](https://github.com/apple/containerization) - Swift framework
- [Virtualization.framework](https://developer.apple.com/documentation/virtualization) - Apple docs
