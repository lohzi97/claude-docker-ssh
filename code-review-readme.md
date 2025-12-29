# Code Review with Claude Code Docker Container

Create a safe environment that contain repo for

## SSH Keys for GitLab Access

To access private GitLab repositories for code review, you need to set up SSH keys for the container.

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

Add this as a **Deploy Key** in GitLab (Settings → Repository → Deploy Keys).

### Restart container

```bash
docker-compose down
docker-compose up --build
``` 