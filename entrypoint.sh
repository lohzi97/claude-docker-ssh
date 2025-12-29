#!/bin/bash
set -e

# Fix ownership of /home/claude/.claude to ensure claude user can write
# This handles cases where the mounted volume has incorrect permissions
if [ -d /home/claude/.claude ]; then
    chown -R claude:claude /home/claude/.claude
fi

# Fix if Docker created .claude.json as a directory instead of a file
# This happens when the host path doesn't exist - Docker auto-creates a directory
if [ -d /home/claude/.claude.json ]; then
    # Check if it's a bind mount
    if mountpoint -q /home/claude/.claude.json; then
        # It's a bind mount directory - we need to fix this on the host side
        # by removing the directory and creating an empty file
        echo "ERROR: ./config/.claude.json is a directory on the host."
        echo "Run this on your host:"
        echo "  rm -rf config/.claude.json"
        echo "  touch config/.claude.json"
        echo "  docker compose restart"
        exit 1
    else
        # Not a mount, safe to remove
        rm -rf /home/claude/.claude.json
    fi
fi

# Also ensure the entire home directory is owned by claude
chown -R claude:claude /home/claude

# Fix SSH key permissions if mounted
if [ -f /home/claude/.ssh/id_ed25519 ]; then
    chmod 600 /home/claude/.ssh/id_ed25519
    chown claude:claude /home/claude/.ssh/id_ed25519
fi
if [ -f /home/claude/.ssh/id_ed25519.pub ]; then
    chmod 644 /home/claude/.ssh/id_ed25519.pub
    chown claude:claude /home/claude/.ssh/id_ed25519.pub
fi
if [ -f /home/claude/.ssh/config ]; then
    chmod 644 /home/claude/.ssh/config
    chown claude:claude /home/claude/.ssh/config
fi

# Set SSH password from environment variable
if [ -n "$SSH_PASSWORD" ]; then
    echo "claude:$SSH_PASSWORD" | chpasswd
fi

# Start SSH server
exec /usr/sbin/sshd -D
