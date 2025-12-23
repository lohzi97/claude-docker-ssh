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
# Default password: claude-code-123
```

## Architecture

### Container Components

- **Base Image**: `node:20-bullseye-slim`
- **SSH Server**: OpenSSH server running on port 22
- **User**: `claude` with sudo privileges
- **Claude Code**: Installed globally via npm

### Volume Mount

- `./claude_data:/home/claude/.claude` - Persists Claude's authentication tokens, settings, and conversation history

### Networking

The container connects to an external Docker network named `self-hosted-ai-starter-it_demo` (referenced but optional). This allows it to communicate with other containers in an AI starter kit setup.

## Configuration

Claude settings are stored in `claude_data/settings.json`. Use `settings-example.json` as a template. Key settings:

- `ANTHROPIC_BASE_URL`: API endpoint (configured for Z.AI)
- `ANTHROPIC_AUTH_TOKEN`: Your API key
- `ANTHROPIC_DEFAULT_*_MODEL`: Model mappings for Haiku, Sonnet, and Opus
- `alwaysThinkingEnabled`: Enables extended thinking mode

The `.gitignore` excludes `settings.json` to prevent API keys from being committed.

## Container Credentials

- **Username**: `claude`
- **Password**: `claude-code-123`
- **SSH Port**: 22 (map to host port in docker-compose.yml if needed)
