# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Docker container setup for running Claude Code (Anthropic's AI coding assistant) in an isolated, containerized environment with SSH access. The container can be used to let Claude Code make changes safely without affecting the host system.

## Common Commands

```bash
# Build and start the container
docker-compose up --build

# Start the container in detached mode
docker-compose up -d

# Stop the container
docker-compose down

# View logs
docker-compose logs -f

# SSH into the running container
ssh claude@localhost -p 2222
# Default password: claude-code-123 (set via SSH_PASSWORD env var)
```

## Configuration

### SSH Password

Set via `SSH_PASSWORD` environment variable. Default is `claude-code-123`. Override in `docker-compose.yml`:

```yaml
environment:
  - SSH_PASSWORD=your-secure-password-here
```

## Architecture

### Container Components

- **Base Image**: `node:20-bullseye-slim`
- **SSH Server**: OpenSSH server running on port 22
- **User**: `claude` with sudo privileges
- **Claude Code**: Installed globally via npm

### Volume Mount

- `./claude_data:/home/claude/.claude` - Persists Claude's authentication tokens, settings, and conversation history
- `./config/ssh_key` → `/home/claude/.ssh/id_ed25519` - SSH private key for GitLab
- `./config/ssh_key.pub` → `/home/claude/.ssh/id_ed25519.pub` - SSH public key for GitLab
- `./config/ssh_config` → `/home/claude/.ssh/config` - SSH configuration (optional)

## Configuration

Claude settings are stored in `claude_data/settings.json`. Use `settings-example.json` as a template. Key settings:

- `ANTHROPIC_BASE_URL`: API endpoint (configured for Z.AI)
- `ANTHROPIC_AUTH_TOKEN`: Your API key
- `ANTHROPIC_DEFAULT_*_MODEL`: Model mappings for Haiku, Sonnet, and Opus
- `alwaysThinkingEnabled`: Enables extended thinking mode

The `.gitignore` excludes `settings.json` to prevent API keys from being committed.

## SSH Keys for GitLab Access

To access private GitLab repositories from within the container, set up dedicated SSH keys:

### Generate SSH key pair

```bash
ssh-keygen -t ed25519 -f ./config/ssh_key -N ""
```

### (Optional) Create SSH config

For gitlab.com:
```bash
cat > ./config/ssh_config << 'EOF'
Host gitlab.com
    StrictHostKeyChecking no
    User git
EOF
```

For self-hosted GitLab:
```bash
cat > ./config/ssh_config << 'EOF'
Host your-gitlab.example.com
    StrictHostKeyChecking no
    User git
    Port 22
EOF
```

### Add public key to GitLab

```bash
cat ./config/ssh_key.pub
```

Add this as a **Deploy Key** in GitLab (Settings → Repository → Deploy Keys) or as an SSH key to your user account.

### Restart container

```bash
docker-compose down
docker-compose up --build
```

## Container Credentials

- **Username**: `claude`
- **Password**: Set via `SSH_PASSWORD` env var (default: `claude-code-123`)
- **SSH Port**: 22 (map to host port in docker-compose.yml if needed)
