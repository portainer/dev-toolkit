# alapenna-container toolkit

A development environment using Apple's native container CLI on macOS 26+.

## Prerequisites

- macOS 26 (Tahoe) or later
- Apple Silicon Mac
- zsh shell (default on macOS)
- Xcode 27 or later, selected via `xcode-select` — provides `xcrun mcpbridge`, the MCP server that backs the in-container Xcode integration
- `socat` on the host (`brew install socat`) — used to expose `xcrun mcpbridge` over a Unix socket the container can reach
- Xcode headless MCP mode enabled once (`sudo xcrun mcp-server enable`) — lets the tools work with Xcode closed. Optional but recommended; `devbox-apple` warns if it's off

`devbox-apple` will refuse to start the container if `socat` or `xcrun mcpbridge` is missing. If you don't want the Xcode integration, edit `devbox-apple` and remove the `start_xcode_bridge` / `sync_xcode_plugin` calls and the related mounts in `cmd_enter`.

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
| `~/.cache/devbox-apple/xcode-plugin` | `/opt/xcode-plugin` | read-only — Xcode's Claude Code plugin, refreshed on every start |
| `$(getconf DARWIN_USER_TEMP_DIR)ActionArtifacts` | same path | read-only — Xcode MCP screenshots, previews, UI hierarchies, logs |

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
- **AI**: Claude Code with plugins (claude-hud) and opt-in Xcode integration (`clx`)
- **Scripts**: ccm (Claude commit message generator)

## Xcode MCP integration

Claude Code inside the container can drive Xcode on the host through Apple's own MCP server (`xcrun mcpbridge`, Xcode 27+). It exposes ~50 tools: build and run, tests, SwiftUI preview rendering, Swift snippets, LLDB, simulator and device interaction (tap/swipe/type with screenshot + accessibility hierarchy capture), schemes and run destinations, build settings, entitlements, Info.plist, String Catalogs, and project/target creation. `clx` also loads Apple's `xcode-integration` Claude plugin, which ships the matching agent skills (`device-interaction`, `swiftui-specialist`, `translation`, `modernize-tests`, accessibility, …).

### How it works

`mcpbridge` is a macOS-only stdio binary that talks to Xcode over XPC — it can't run inside the Linux container, and it doesn't expose a TCP port. Instead, `devbox-apple` runs a `socat` listener on the Mac that spawns `xcrun mcpbridge` per connection behind a Unix socket, then mounts that socket into the container the same way `/var/run/docker.sock` is mounted.

On every create/resume, `devbox-apple` also copies Xcode's packaged Claude plugin (`xcrun agent plugin path --plugin-format claude`) to `~/.cache/devbox-apple/xcode-plugin` and rewrites its `.mcp.json` to relay stdio to the mounted socket via in-container `socat` (the shipped one runs `xcrun mcpbridge`, which doesn't exist in the container). Xcode materializes the plugin under a build-numbered path, so the stable copy is what gets mounted — an Xcode update is picked up on the next `devbox-apple stop && devbox-apple`, no rebuild.

Tool results return **host** file paths for screenshots, preview snapshots, UI hierarchies and full logs (under `$TMPDIR/ActionArtifacts`). That directory is mounted read-only at the same absolute path in the container, so those paths open as-is — this is what lets Claude visually verify UI changes.

### Headless mode and approvals

With headless mode on (`sudo xcrun mcp-server enable`, once), the tools work with Xcode closed: the headless service launches on demand. Without it, they only work against a running Xcode.

The first time an agent opens a project (`XcodeOpenWorkspace`), macOS asks you to approve the agent and that project's folder — choose **Always Allow**. Tools other than open/create refuse to run until then. To pre-approve every project under the workspace in one go:

```bash
sudo xcrun mcp-server allow-folder ~/workspaces/applecntr-workspace --always
```

Grants are managed with `xcrun mcp-server status`, `sudo xcrun mcp-server deny <id>` and `sudo xcrun mcp-server clear-permissions`.

### Enabling it (opt-in)

The Xcode integration is **not** auto-loaded. Plain `claude` (or the `cl` alias) is a vanilla session — use it for non-Apple work. For Apple projects, launch Claude with `clx`:

```bash
clx   # = claude --dangerously-skip-permissions --plugin-dir /opt/xcode-plugin
```

The listener uses `socat … fork`, so several `clx` sessions can run at once (each gets its own `mcpbridge`). Two sessions driving the same simulator will still step on each other.

Simulator interaction sessions (`DeviceInteraction*`) expire after a few idle minutes (`Session not found`). Claude just starts a new one.

### Lifecycle

The bridge is tied to the container — there is no always-on listener on the Mac.

| `devbox-apple` action | Bridge effect |
|-----------------------|---------------|
| Create container (first run) | Spawns `socat` listener, syncs the plugin, bakes the socket/plugin/artifacts mounts into the container |
| Resume stopped container | Re-spawns `socat` listener and re-syncs the plugin (mounts were baked in at create time) |
| `devbox-apple stop` | Kills the listener, removes socket and PID files |
| `devbox-apple destroy` | Same teardown as `stop` |
| External `container stop devbox-apple` | Listener orphans; reaped on next `devbox-apple` start or stop |

> The socket must exist **before** `container start`, and must not be recreated while the container runs. The container stays attached to the socket that existed at start; a socket recreated at the same path leaves it talking to a dead endpoint (connect succeeds, then `Connection reset by peer`). If you restart the listener by hand, restart the container too: `devbox-apple stop && devbox-apple`.

### Verifying the connection

Inside the container:

```bash
ls -la /var/run/xcode-mcp.sock   # leading 's' = Unix socket, mount worked
ls /opt/xcode-plugin/skills      # Apple's skills are mounted
```

Then start Claude with `clx` and run `/mcp` — the plugin's `xcode` server should be `connected`. (Plain `claude`/`cl` won't list it — that's expected.)

### Troubleshooting

Bridge log on the Mac (socat errors and `mcpbridge` stderr):

```bash
tail -f ~/tmp/dev-toolkit/.xcode-mcp.log
```

Xcode's side — headless service state, pending approval requests, open workspaces, and the agent activity log:

```bash
xcrun mcp-server status
less "$(xcrun mcp-server show-logs)"
```

Other quick checks:

```bash
# Mac: is the listener running?
cat ~/tmp/dev-toolkit/.xcode-mcp.pid && ps -p "$(cat ~/tmp/dev-toolkit/.xcode-mcp.pid)"

# Mac: MCP handshake end-to-end through the socket (keep stdin open so it can reply)
(printf '%s\n' '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-06-18","capabilities":{},"clientInfo":{"name":"probe","version":"0"}}}'; sleep 5) \
  | socat - UNIX-CONNECT:$HOME/tmp/dev-toolkit/xcode-mcp.sock
```

If the Mac-side handshake works but the container gets `Connection reset by peer`, the socket was recreated after the container started — `devbox-apple stop && devbox-apple`.

### Security properties

- Socket lives at mode `600` in `~/tmp/dev-toolkit/` — only your user can connect.
- No network port, no remote login enabled on the host.
- Xcode gates access per agent and per project folder (see approvals above); headless mode is off until you `sudo` enable it.
- The plugin and artifacts mounts are read-only.

### Migrating from XcodeBuildMCP

Earlier versions of this toolkit used [XcodeBuildMCP](https://www.xcodebuildmcp.com/). To switch:

```bash
# On the Mac
sudo xcrun mcp-server enable
brew uninstall xcodebuildmcp
brew untap getsentry/xcodebuildmcp
claude mcp list                # host Claude, if installed: remove any XcodeBuildMCP entry
rm -rf ~/.xcodebuildmcp        # leftover config, if present

# Recreate the container (new mounts are baked in at create time) with the new image
cp devbox-apple ~/.local/bin/
devbox-apple rebuild
devbox-apple
```

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

### Cloudflare WARP coexistence (`DNS_SERVERS`)

apple/container normally resolves container DNS through a resolver on the Mac that surfaces as `mDNSResponder` holding port 53. Cloudflare WARP needs to own port 53 to run its own DNS proxy, so when both are active WARP fails to connect with:

```
CF_DNS_PROXY_FAILURE — A third-party process is performing DNS resolution
on this device: mDNSResponder.
```

To let WARP start, free port 53 before connecting it: `container system stop` → connect WARP → `container system start`. But once WARP owns port 53, the container's default resolution path is gone — so the container needs an **explicit** resolver or it gets no DNS at all. That's what the `DNS_SERVERS` variable near the top of `devbox-apple` provides (default `1.1.1.1 1.0.0.1`), passed as `--dns` flags on `container run`.

**Tradeoff:** a public resolver means the container resolves **public DNS only**. WARP / Zero-Trust *private* hostnames will not resolve inside the box — reach those internal services by direct IP. There is no `--dns` value that recovers private resolution: WARP's resolver is bound to the Mac's loopback (`127.0.0.2`/`127.0.0.3`), which is unreachable from the container's separate network namespace. The only way to get WARP-aware DNS inside the container would be to enroll the VM in WARP itself.

To restore default (host-inherited) resolution instead — e.g. if you don't run WARP — set `DNS_SERVERS=()` empty.

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
