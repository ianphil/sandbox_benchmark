#!/bin/bash

# Script to recursively find and delete .git folders
# Usage: ./remove_git_folders.sh [path]
# If no path is provided, uses current directory

TARGET_DIR="${1:-.}"

echo "Searching for .git folders in: $TARGET_DIR"
echo "-------------------------------------------"

# Find all .git directories (excluding the root .git folder) and count them
git_folders=$(find "$TARGET_DIR" -mindepth 2 -type d -name ".git" 2>/dev/null)
count=$(echo "$git_folders" | grep -c ".git" || echo "0")

if [ "$count" -eq 0 ]; then
    echo "No .git folders found."
    exit 0
fi

echo "Found $count .git folder(s):"
echo "$git_folders"
echo "-------------------------------------------"

# Ask for confirmation
read -p "Do you want to delete these folders? (y/N): " confirm

if [[ $confirm =~ ^[Yy]$ ]]; then
    echo "Deleting .git folders..."
    find "$TARGET_DIR" -mindepth 2 -type d -name ".git" -exec rm -rf {} + 2>/dev/null
    echo "Done! Deleted $count .git folder(s)."
else
    echo "Operation cancelled."
fi
