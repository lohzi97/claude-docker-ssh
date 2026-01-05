#!/bin/bash

################################################################################
# Git Repository Cloner
################################################################################
#
# DESCRIPTION:
#   This script checks if a local Git repository matching a given remote URL
#   already exists within a specified directory. If found, it reports the
#   location. If not found, it clones the repository to a target location.
#
# USAGE:
#   ./clone_repo.sh <git-url> <search-directory> [<target-directory>]
#
# ARGUMENTS:
#   git-url           The Git repository URL to search for or clone. Can be
#                     in HTTPS format (https://github.com/user/repo.git) or
#                     SSH format (git@github.com:user/repo.git).
#
#   search-directory  The local directory path to search for existing clones.
#                     The script will recursively search all subdirectories.
#
#   target-directory  (Optional) Directory where the repo should be cloned if
#                     not found. Defaults to <search-directory>/<name>.
#
# EXAMPLES:
#   ./clone_repo.sh https://github.com/user/repo.git ~/Projects
#   ./clone_repo.sh git@github.com:user/repo.git ~/Projects ~/Projects/my-repo
#
# OUTPUT:
#   - "Repository already exists at: <path>" if found
#   - "Cloning to <target>..." followed by clone progress if not found
#
# EXIT CODES:
#   0 - Success (repo found or cloned successfully)
#   1 - Error (invalid arguments, directory not found, or clone failed)
#
################################################################################

# Check for minimum required arguments
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: $0 <git-url> <search-directory> [<target-directory>]"
    echo "Example: $0 https://github.com/user/repo.git ~/Projects"
    exit 1
fi

INPUT_URL="$1"
# Remove trailing slash from search directory to avoid double slashes in paths
SEARCH_DIR="${2%/}"
TARGET_DIR="${3:-}"

# Ensure the search directory exists
if [ ! -d "$SEARCH_DIR" ]; then
    echo "Error: Directory $SEARCH_DIR does not exist."
    exit 1
fi

# Function to extract a unique project identifier (path) from any Git URL
get_repo_id() {
    echo "$1" | sed -E 's|https?://[^/]+/||' | sed -E 's|git@[^:]+:||' | sed 's|\.git$||' | sed 's|/$||'
}

# Function to extract just the repo name from the URL
get_repo_name() {
    get_repo_id "$1" | grep -o '[^/]*$'
}

TARGET_ID=$(get_repo_id "$INPUT_URL")
REPO_NAME=$(get_repo_name "$INPUT_URL")

echo "Searching for: $TARGET_ID"
echo "Inside: $SEARCH_DIR"
echo "----------------------------------------------------------"

FOUND_COUNT=0
FOUND_PATH=""

# Search for existing repository
while IFS= read -r gitdir; do
    repo_path=$(dirname "$gitdir")
    LOCAL_REMOTE=$(git -C "$repo_path" config --get remote.origin.url)

    if [ -n "$LOCAL_REMOTE" ]; then
        LOCAL_ID=$(get_repo_id "$LOCAL_REMOTE")

        if [ "$TARGET_ID" == "$LOCAL_ID" ]; then
            echo "[MATCH FOUND]"
            echo "Location: $repo_path"
            echo "Remote:   $LOCAL_REMOTE"
            echo "----------------------------------------------------------"
            ((FOUND_COUNT++))
            FOUND_PATH="$repo_path"
        fi
    fi
done < <(find "$SEARCH_DIR" -name ".git" -type d -prune 2>/dev/null)

# If found, fetch updates and exit
if [ "$FOUND_COUNT" -gt 0 ]; then
    echo "Repository already exists at: $FOUND_PATH"
    echo "Fetching updates..."
    if git -C "$FOUND_PATH" fetch; then
        echo "Successfully fetched updates."
        exit 0
    else
        echo "Error: Failed to fetch updates."
        exit 1
    fi
fi

# Not found - proceed to clone
echo "No matching repository found."

# Set target directory if not specified
if [ -z "$TARGET_DIR" ]; then
    TARGET_DIR="$SEARCH_DIR/$REPO_NAME"
fi

echo "Cloning to: $TARGET_DIR"
echo "----------------------------------------------------------"

# Create parent directory if it doesn't exist
PARENT_DIR=$(dirname "$TARGET_DIR")
if [ ! -d "$PARENT_DIR" ]; then
    mkdir -p "$PARENT_DIR"
fi

# Check if target already exists (as a directory)
if [ -e "$TARGET_DIR" ]; then
    echo "Error: Target path $TARGET_DIR already exists."
    exit 1
fi

# Fix SSH private key permissions if they exist and are too open
SSH_DIR="$HOME/.ssh"
if [ -d "$SSH_DIR" ]; then
    # Fix .ssh directory permissions
    chmod 700 "$SSH_DIR" 2>/dev/null

    # Fix all private key files (.pem, id_rsa, id_ed25519, id_ecdsa, id_dsa)
    find "$SSH_DIR" -type f \( -name "*.pem" -o -name "id_rsa" -o -name "id_ed25519" -o -name "id_ecdsa" -o -name "id_dsa" \) -exec chmod 600 {} \; 2>/dev/null

    # Fix public key files
    find "$SSH_DIR" -type f \( -name "*.pub" -o -name "known_hosts" -o -name "config" \) -exec chmod 644 {} \; 2>/dev/null
fi

# Clone the repository
# Auto-accept SSH host keys to avoid interactive prompt
if GIT_SSH_COMMAND="ssh -o StrictHostKeyChecking=no" git clone "$INPUT_URL" "$TARGET_DIR"; then
    echo "----------------------------------------------------------"
    echo "Successfully cloned to: $TARGET_DIR"
    exit 0
else
    echo "Error: Failed to clone repository."
    exit 1
fi
