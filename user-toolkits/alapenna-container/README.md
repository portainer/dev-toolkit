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
- zsh shell (default on macOS)

## Installing Apple Container CLI

Follow the official installation guide: [apple/container - Install or Upgrade](https://github.com/apple/container?tab=readme-ov-file#install-or-upgrade)

Verify installation:

```bash
container --version
container system status
```

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
- **AI**: Claude Code with plugins (claude-hud, plannotator on port 17777)
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

**Mismatch warnings:** If an existing builder doesn't match the recommended `performance` profile, you'll be warned before the build starts.

### Script Defaults

The script default is the **performance** profile (8 CPUs / 8g) - this is the recommended configuration for optimal build speed.

If you want to permanently use a different profile:

1. Edit `devbox-apple` script
2. Set `BUILDER_CPUS` and `BUILDER_MEMORY` to your preferred values
   - Example: `BUILDER_CPUS=4` and `BUILDER_MEMORY="4g"` for balanced
3. All new builders will use these defaults

**Note:** The mismatch warning will always check against the performance profile (8 CPUs / 8g) regardless of script defaults, as this is the recommended configuration.

### Keeping Builder Between Builds

During active Dockerfile development (frequent rebuilds), keep the builder to avoid recreation overhead:

```bash
devbox-apple rebuild --keep-builder  # Builder stays after build
devbox-apple rebuild --keep-builder  # Reuses existing builder (fast!)
devbox-apple rebuild                 # Final build removes builder
```

### Builder Behavior Summary

| Scenario | Builder Action | Notes |
|----------|----------------|-------|
| First build | Creates with script defaults | Uses BUILDER_CPUS/BUILDER_MEMORY (performance profile) |
| Build completes | Auto-removes (frees resources) | Unless `--keep-builder` used |
| Existing builder found | Uses existing config | Warns if not performance profile (8 CPUs / 8g) |
| `builder-configure` called | Replaces with new profile | Persists until auto-removed |
| No profile specified | Uses performance | `devbox-apple builder-configure` → performance profile |

## Port Configuration

The container exposes ports **10000-19999** (mapped 1:1 to host) to avoid conflicts with system services.

### Pre-configured Services

| Port | Service |
|------|---------|
| 17777 | Plannotator |

## Isolation Benefits

Unlike OrbStack which [auto-mounts /Users and /Volumes](https://github.com/orbstack/orbstack/issues/169), Apple container only mounts what you explicitly configure. This makes it suitable for running untrusted code (like AI agents) in a sandboxed environment.

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
