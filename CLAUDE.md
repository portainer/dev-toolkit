# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

The Portainer dev-toolkit is a containerized development environment for Portainer development. It provides a devcontainer-based setup on Ubuntu 24.04 that can be used with any IDE supporting the devcontainer specification.

## Installed Tools

- **Go** (v1.26.4) - Portainer backend development
- **Docker CLI** (v29.5.3) + **Docker Compose** (v5.1.4) - Container management via mounted host socket
- **Node.js** (v24.16.0) + **Yarn** (v1.22.22) - Portainer frontend development
- **golangci-lint** (v2.12.2) - Go code linting
- **gopls** (v0.22.0) - Go language server for LSP support

## Build Commands

```bash
# Build and push multi-arch base image (requires DockerHub auth)
make base

# Build single-arch images
make base-amd64
make base-arm64

# Build custom user toolkit
make alapenna
make alapenna-ghostty
```

## Building Portainer Inside the Toolkit

Once inside the devcontainer:

```bash
# Install dependencies and build client+server
make build-all

# Run the backend
./dist/portainer --data /tmp/portainer --log-level=DEBUG

# Run client in dev mode (for frontend changes)
make dev-client
```

## Architecture

### Core Files
- `Dockerfile` - Base image with all development tools
- `devcontainer.json` - Devcontainer config; mounts Docker socket at `/var/run/docker.sock` for container operations from within the devcontainer
- `post-start.sh` - Runs on container start; cleans /tmp files older than 8 hours to prevent disk bloat from builds

### Port Forwarding
Ports exposed via devcontainer.json: 8000, 8999, 9000, 9443 (Portainer's default ports)

### Extension Points
- `examples/` - Reference customizations (zsh, Python extension)
- `user-toolkits/` - Personal configurations extending the base image

### CI/CD
GitHub Actions workflow builds multi-arch images (amd64, arm64) on tag push and publishes to `portainer/dev-toolkit` on DockerHub.

## Creating Custom Toolkits

1. Reference `examples/zsh/Dockerfile` or `user-toolkits/alapenna/Dockerfile` as starting points
2. Create a Dockerfile extending `portainer/dev-toolkit:2026.06`
3. Build: `docker buildx build -t my-devkit -f path/to/Dockerfile .`
4. Update `devcontainer.json` image field to use your custom image

## Troubleshooting from Inside a Devbox

When the user reports an issue from a running devbox container, check `$DEVBOX_GIT_COMMIT` to see which commit the image was built from. A `-dirty` suffix means the build included uncommitted local changes. If the value disagrees with the user's expectation (e.g. they expected a recent fix to be present), the image likely wasn't actually rebuilt.

## Apple Container Build Failures

If `make alapenna-container` (or any `container build` against `user-toolkits/alapenna-container/`) fails immediately with `Error: unavailable: "Stream unexpectedly closed."` — this is [apple/container#735](https://github.com/apple/container/issues/735), a ~16KB gRPC header cap on the Dockerfile. The CLI dies before buildkit ever sees the build. Comments and blank lines count toward the limit. Fix: shrink the Dockerfile (strip inline comments, move long-form rationale to the toolkit README). Do not bisect the Dockerfile content looking for a "bad" line — the file is structurally fine, it just exceeds the wire-level cap.

## Version Management

Current version: `VERSION=2026.06` in Makefile. Releasing:
1. Update VERSION in Makefile
2. Create and push a git tag matching the version
3. GitHub Actions automatically builds and pushes multi-arch images to DockerHub
