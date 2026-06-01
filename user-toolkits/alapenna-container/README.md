# alapenna-container toolkit

A development environment using Apple's native container CLI on macOS 26+.

## Prerequisites

- macOS 26 (Tahoe) or later
- Apple Silicon Mac
- zsh shell (default on macOS)
- Xcode 16 or later with command-line tools
- [`xcodebuildmcp`](https://www.xcodebuildmcp.com/) on the host (`brew install getsentry/xcodebuildmcp/xcodebuildmcp`) — the MCP server that backs the in-container Xcode integration
- `socat` on the host (`brew install socat`) — used to expose `xcodebuildmcp` over a Unix socket the container can reach

`devbox-apple` will refuse to start the container if `socat` or `xcodebuildmcp` is missing. If you don't want the Xcode integration, edit `devbox-apple` and remove the `start_xcode_bridge` calls in `cmd_enter`.

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

## Directory Configuration

### Volume Mounts (Live-Synced)

| Host | Container | Access |
|------|-----------|--------|
| `~/workspaces/applecntr-workspace` | `/workspace` | read-write |
| `~/tmp/dev-toolkit` | `/share-tmp` | read-write |
| `/var/run/docker.sock` | `/var/run/docker.sock` | read-write (auto-detected) |
| `~/tmp/dev-toolkit/xcode-mcp.sock` | `/var/run/xcode-mcp.sock` | Xcode MCP bridge socket (managed by `devbox-apple`) |

These directories are mounted and changes sync immediately between host and container. The Docker socket is mounted automatically when detected on the host. The Xcode MCP socket is created by `devbox-apple` on container start and torn down on stop — see [Xcode MCP integration](#xcode-mcp-integration) below.

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
- **AI**: Claude Code with plugins (claude-hud) and an opt-in Xcode MCP server (`clx`)
- **Scripts**: ccm (Claude commit message generator)

## Xcode MCP integration

Claude Code inside the container can drive Xcode tooling on the host via [xcodebuildmcp](https://www.xcodebuildmcp.com/) — an MCP server that exposes ~79 tools across iOS, macOS, watchOS, tvOS, and visionOS workflows.

### How it works

`xcodebuildmcp` is a macOS-only stdio binary that shells out to `xcodebuild`, `xcrun`, `simctl`, and `devicectl` — it can't run inside the Linux container directly, and it doesn't expose a TCP port. Instead, `devbox-apple` runs a `socat` listener on the Mac that wraps `xcodebuildmcp mcp` behind a Unix socket, then mounts that socket into the container the same way `/var/run/docker.sock` is mounted. Inside the container, an MCP config file at `/etc/xcode-mcp.json` relays Claude's stdio to the mounted socket via in-container `socat`.

### Enabling it (opt-in, one session at a time)

The Xcode MCP is **not** auto-loaded. Plain `claude` (or the `cl` alias) starts with no Xcode integration. To get it, launch Claude with the `clx` alias instead:

```bash
clx   # = claude --dangerously-skip-permissions --mcp-config /etc/xcode-mcp.json
```

This is deliberate. The host listener serves **one connection at a time** (`socat UNIX-LISTEN` without `fork`), so if every session auto-connected, a second Claude instance would contend for the single slot and knock the first one offline (`Failed to reconnect to xcode: -32000`). Making it opt-in means only the session you launch with `clx` touches the bridge.

> Run `clx` in only **one** tab at a time. A second `clx` session will fight the first for the single slot. If you genuinely need two concurrent Xcode sessions, add `fork` to the `socat UNIX-LISTEN` line in `devbox-apple` (spawns one `xcodebuildmcp` per connection — watch out for two sessions driving the same simulator).

### Workflow scoping

The bridge is scoped to iOS+macOS-relevant workflows by default via `XCODEBUILDMCP_ENABLED_WORKFLOWS`. To adjust, edit `XCODEBUILDMCP_WORKFLOWS` near the top of `devbox-apple` — see the [workflows reference](https://www.xcodebuildmcp.com/docs/workflows) for the full list. To enable Xcode IDE-only features (preview rendering, Issue Navigator, doc search), add `xcode-ide` to the list — that workflow proxies `xcrun mcpbridge` under the hood and requires Xcode 26.3+ with the **Xcode Tools** toggle in *Xcode → Settings → Intelligence*.

### Lifecycle

The bridge is tied to the container — there is no always-on listener on the Mac.

| `devbox-apple` action | Bridge effect |
|-----------------------|---------------|
| Create container (first run) | Spawns `socat` listener, bakes the socket mount into the container |
| Resume stopped container | Re-spawns `socat` listener (mount was baked in at create time) |
| `devbox-apple stop` | Kills the listener, removes socket and PID files |
| `devbox-apple destroy` | Same teardown as `stop` |
| External `container stop devbox-apple` | Listener orphans; reaped on next `devbox-apple` start or stop |

### Verifying the connection

Inside the container:

```bash
ls -la /var/run/xcode-mcp.sock   # leading 's' = Unix socket, mount worked
```

Then start Claude with `clx` and run `/mcp` — `xcode` should be `connected`. (Plain `claude`/`cl` won't list it — that's expected; the server is only loaded via `clx`.)

### Troubleshooting

Bridge log on the Mac (most useful first stop for any "xcode failed to reconnect" / unhealthy MCP issue):

```bash
tail -f ~/tmp/dev-toolkit/.xcode-mcp.log
```

What it shows: `xcodebuildmcp` startup banner and registered workflows, per-call traces, errors from the host-side server. If the log is empty, the listener didn't start — check `socat` and `xcodebuildmcp` are on `$PATH` on the Mac.

Other quick checks:

```bash
# Mac: is the listener running?
cat ~/tmp/dev-toolkit/.xcode-mcp.pid && ps -p "$(cat ~/tmp/dev-toolkit/.xcode-mcp.pid)"

# Mac: connect manually to confirm the socket end-to-end
socat - UNIX-CONNECT:$HOME/tmp/dev-toolkit/xcode-mcp.sock

# Container: socket present and is a socket (leading 's')?
ls -la /var/run/xcode-mcp.sock
```

If the bridge is wedged, `devbox-apple stop && devbox-apple` re-spawns the listener cleanly.

### Security properties

- Socket lives at mode `600` in `~/tmp/dev-toolkit/` — only your user can connect.
- No network port, no remote login enabled on the host.
- `xcodebuildmcp` is spawned per-connection with the same blast radius as you running it manually.

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

## Networking

The container runs on apple/container's default network — no port range is published. Services bound to `0.0.0.0` inside the container are reachable from the Mac directly at the container's IP:

```bash
devbox-apple status              # prints the container's IP
# Container: running
# IP:        192.168.64.2
#            (services bound to 0.0.0.0 in-container reachable at http://192.168.64.2:<port>)
```

Then from your Mac browser/CLI:

```
http://192.168.64.2:5173/        # Vite, etc.
```

Practical notes:
- Services that bind only to `127.0.0.1` (Vite's default, for instance) are *not* reachable from the Mac. Use `--host` / `host: true` / equivalent to bind to all interfaces.
- This trades a little discoverability (you need the IP) for honesty (no aliasing through localhost). And no port collisions with whatever else is running on your Mac.
- **macOS Local Network permission is per-app.** If `curl` from the Mac reaches the container fine but a browser shows `ERR_ADDRESS_UNREACHABLE`, the browser hasn't been granted Local Network access. Open *System Settings → Privacy & Security → Local Network* and enable the browser (Arc, Chrome, etc.). Safari is implicitly trusted; `curl` inherits Terminal's grant.

### No IPv6 egress (`RES_OPTIONS=no-aaaa`)

The apple/container network has no IPv6 egress. Node's resolver still returns AAAA records (it skips `AI_ADDRCONFIG`), so `pnpm`/`npm`/`node` stall trying to connect to dead IPv6 addresses. The image sets `ENV RES_OPTIONS=no-aaaa` in the Dockerfile to tell glibc's resolver to skip AAAA queries entirely — applied at runtime to every shell, node, and pnpm process (and as a bonus to the build's `npm install`/`curl` steps).

### Why not use `--publish`?

Direct IP access on the default network is cleaner: no port-collision juggling with whatever else is running on your Mac, and `http://<container-ip>:<port>` is honest about where the service actually lives.

## Known Limitations

- **No snapshots yet**: The `container` CLI doesn't expose VM snapshot/restore (though Virtualization.framework supports it)
- **Pre-1.0**: API may change between versions
- **Image unpacking**: Can be slow for large images
- **Dockerfile size cap (~16KB)**: `container build` sends the Dockerfile in a gRPC header, which is bound by gRPC's 16KB default. Hitting the cap fails immediately with `Error: unavailable: "Stream unexpectedly closed."` (or `Transport became inactive` on older CLI versions) — see [apple/container#735](https://github.com/apple/container/issues/735). Workaround: keep the Dockerfile lean. Inline comments and blank lines count toward the limit, so when adding heavy explanatory prose, put it in a sibling notes file rather than inside the Dockerfile.

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

### `container build` fails with "Stream unexpectedly closed"

Almost always means you've crossed the ~16KB Dockerfile size cap (gRPC header limit, [apple/container#735](https://github.com/apple/container/issues/735)). The build dies in milliseconds, before reaching buildkit — `container logs buildkit` will show no session for the failed attempt.

Confirm by stripping inline comments / blank lines from the Dockerfile until the build succeeds. Long-form rationale belongs in this README or a notes file, not in the Dockerfile.

## References

- [apple/container](https://github.com/apple/container) - CLI tool
- [apple/containerization](https://github.com/apple/containerization) - Swift framework
- [Virtualization.framework](https://developer.apple.com/documentation/virtualization) - Apple docs
