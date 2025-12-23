# Claude Code Docker Container

A Docker container setup for running [Claude Code](https://claude.ai/code) (Anthropic's AI coding assistant) in an isolated, containerized environment with SSH access. This allows Claude Code to make changes safely without affecting the host system.

## Features

- **Isolated Environment**: Run Claude Code in a separate Docker container
- **SSH Access**: Connect to the container via SSH for remote development
- **Persistent Storage**: Claude's authentication tokens, settings, and conversation history are preserved across container restarts
- **Z.AI Integration**: Pre-configured for Z.AI API endpoint with GLM model mappings

## Quick Start

```bash
# Build and start the container
docker-compose up --build

# Start in detached mode (runs in background)
docker-compose up -d

# SSH into the running container
ssh claude@localhost -p 2222
# Default password: claude-code-123
```

## Configuration

### API Settings

Copy `settings-example.json` to `settings.json` and configure your API credentials:

```bash
cp claude_data/settings-example.json claude_data/settings.json
```

Edit `claude_data/settings.json` with your settings:

```json
{
  "env": {
    "ANTHROPIC_BASE_URL": "https://api.z.ai/api/anthropic",
    "ANTHROPIC_AUTH_TOKEN": "your-api-key-here",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL": "glm-4.5-air",
    "ANTHROPIC_DEFAULT_SONNET_MODEL": "glm-4.6",
    "ANTHROPIC_DEFAULT_OPUS_MODEL": "glm-4.6"
  },
  "alwaysThinkingEnabled": true
}
```

### Container Credentials

| Setting | Value |
|---------|-------|
| Username | `claude` |
| Password | `claude-code-123` |
| SSH Port | 22 (map to host port in docker-compose.yml if needed) |

## Docker Commands

```bash
# Start the container
docker-compose up -d

# Stop the container
docker-compose down

# View logs
docker-compose logs -f

# Restart the container
docker-compose restart

# SSH into the container
ssh claude@localhost -p 2222
```

## Architecture

The container is built on `node:20-bullseye-slim` and includes:

- **OpenSSH Server**: For remote SSH access
- **Git**: For version control operations
- **Claude Code**: Installed globally via npm
- **User Account**: `claude` with sudo privileges

### Volume Mounts

| Host Path | Container Path | Purpose |
|-----------|----------------|---------|
| `./claude_data` | `/home/claude/.claude` | Claude settings and history |

## Project Structure

```
.
├── Dockerfile                 # Container image definition
├── docker-compose.yml         # Docker Compose configuration
├── CLAUDE.md                  # Claude Code project instructions
├── README.md                  # This file
├── .gitignore                 # Git ignore rules
└── claude_data/
    ├── settings.json          # Claude settings (not in git)
    └── settings-example.json  # Settings template
```

## Security Notes

- The default password should be changed in production environments
- API keys are excluded from git via `.gitignore`
- Consider using SSH keys instead of password authentication for production use
