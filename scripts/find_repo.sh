#!/bin/bash

################################################################################
# Git Repository Finder
################################################################################
#
# DESCRIPTION:
#   This script searches for local Git repositories that match a given remote
#   Git URL within a specified directory tree. It normalizes both the provided
#   URL and all local repository remote URLs to compare them, making it capable
#   of finding matches regardless of URL format differences (HTTPS vs SSH).
#
# USAGE:
#   ./script.sh <git-url> <search-directory>
#
# ARGUMENTS:
#   git-url           The Git repository URL to search for. Can be in HTTPS
#                     format (https://github.com/user/repo.git) or SSH format
#                     (git@github.com:user/repo.git).
#
#   search-directory  The local directory path where the search should begin.
#                     The script will recursively search all subdirectories
#                     for Git repositories.
#
# EXAMPLES:
#   ./script.sh https://github.com/user/repo.git ~/Projects
#   ./script.sh git@github.com:user/repo.git /home/user/workspace
#
# HOW IT WORKS:
#   1. Validates that both required arguments are provided
#   2. Verifies that the search directory exists
#   3. Normalizes the input Git URL to extract a unique repository identifier
#      (removes protocol, domain, and .git extension)
#   4. Recursively finds all .git directories within the search path
#   5. For each Git repository found, retrieves its remote.origin.url
#   6. Normalizes each local repository's URL using the same method
#   7. Compares the normalized identifiers to find matches
#   8. Reports all matching repositories with their local paths and remote URLs
#
# OUTPUT:
#   - Displays search parameters at the start
#   - For each match found, displays:
#     * "[MATCH FOUND]" header
#     * Local repository location (absolute path)
#     * Remote URL configured for origin
#   - Reports total count (or "No matching repository found" if none)
#
# REQUIREMENTS:
#   - Bash shell
#   - git command-line tool installed and in PATH
#   - find utility (standard on Unix-like systems)
#   - sed utility (standard on Unix-like systems)
#   - Read permissions on the search directory and its subdirectories
#
# EXIT CODES:
#   0 - Success (search completed, matches found or not)
#   1 - Error (missing arguments or invalid search directory)
#
# NOTES:
#   - The script ignores errors from 'find' (e.g., permission denied on some
#     directories) by redirecting stderr to /dev/null
#   - Only checks the 'origin' remote; repositories with different remote
#     names won't be matched
#   - Case-sensitive comparison is used for repository identifiers
#
################################################################################

# Check for minimum required arguments
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: $0 <git-url> <search-directory>"
    echo "Example: $0 https://github.com/user/repo.git ~/Projects"
    exit 1
fi

INPUT_URL="$1"
SEARCH_DIR="$2"

# Ensure the search directory exists
if [ ! -d "$SEARCH_DIR" ]; then
    echo "Error: Directory $SEARCH_DIR does not exist."
    exit 1
fi

# Function to extract a unique project identifier (path) from any Git URL
get_repo_id() {
    echo "$1" | sed -E 's|https?://[^/]+/||' | sed -E 's|git@[^:]+:||' | sed 's|\.git$||' | sed 's|/$||'
}

TARGET_ID=$(get_repo_id "$INPUT_URL")

echo "Searching for: $TARGET_ID"
echo "Inside: $SEARCH_DIR"
echo "----------------------------------------------------------"

FOUND_COUNT=0

# Use 'find' to locate all .git directories within the specified path
# -type d: directories only
# -name ".git": folders named .git
# -prune: don't search inside the .git folder itself
while IFS= read -r gitdir; do
    # Get the parent directory of the .git folder
    repo_path=$(dirname "$gitdir")
    
    # Get the remote URL of this local repo
    LOCAL_REMOTE=$(git -C "$repo_path" config --get remote.origin.url)
    
    if [ -n "$LOCAL_REMOTE" ]; then
        LOCAL_ID=$(get_repo_id "$LOCAL_REMOTE")
        
        # Compare normalized IDs
        if [ "$TARGET_ID" == "$LOCAL_ID" ]; then
            echo "[MATCH FOUND]"
            echo "Location: $repo_path"
            echo "Remote:   $LOCAL_REMOTE"
            echo "----------------------------------------------------------"
            ((FOUND_COUNT++))
        fi
    fi
done < <(find "$SEARCH_DIR" -name ".git" -type d -prune 2>/dev/null)

if [ "$FOUND_COUNT" -eq 0 ]; then
    echo "No matching repository found."
fi