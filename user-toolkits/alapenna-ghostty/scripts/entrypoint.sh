#!/bin/bash
# Container entrypoint - runs on every container start

# Clean tmp files older than 8 hours to prevent disk bloat from builds
find /tmp -mindepth 1 -mmin +480 -exec rm -rf {} \; 2>/dev/null || true

# Remove docker config (prevents credential conflicts with host)
rm -f /root/.docker/config.json 2>/dev/null || true

# Keep container running
exec sleep infinity
