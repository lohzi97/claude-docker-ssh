# File: ~/ai-agent/Dockerfile
FROM node:20-bullseye-slim

# Install SSH, Git, and process managers
RUN apt-get update && apt-get install -y \
    openssh-server \
    git \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Setup SSH directory
RUN mkdir /var/run/sshd

# Create a user to connect as
RUN useradd -m -s /bin/bash claude && \
    echo "claude:claude-code-123" | chpasswd && \
    adduser claude sudo

# Install Claude Code globally
RUN npm install -g @anthropic-ai/claude-code

# Ensure the claude user owns their home
WORKDIR /home/claude
USER claude

# Expose SSH port
EXPOSE 22

# Create entrypoint to fix permissions and start SSH
USER root
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
CMD ["/usr/local/bin/entrypoint.sh"]