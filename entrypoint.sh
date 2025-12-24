#!/bin/bash
set -e

# Fix ownership of /home/claude/.claude to ensure claude user can write
# This handles cases where the mounted volume has incorrect permissions
if [ -d /home/claude/.claude ]; then
    chown -R claude:claude /home/claude/.claude
fi

# Fix if Docker created .claude.json as a directory instead of a file
if [ -d /home/claude/.claude.json ]; then
    rm -rf /home/claude/.claude.json
fi

# Also ensure the entire home directory is owned by claude
chown -R claude:claude /home/claude

# Start SSH server
exec /usr/sbin/sshd -D
