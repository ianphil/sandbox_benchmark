#!/bin/bash

# Script to clean up agent folders after benchmark runs
# Removes generated files but preserves the folder structure

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "AI Agent Folder Cleanup"
echo "======================="
echo "Workspace: $WORKSPACE_DIR"
echo ""

# Find all agent folders
agent_folders=$(find "$WORKSPACE_DIR" -maxdepth 1 -type d -name "simple_sandbox_*" 2>/dev/null)

if [ -z "$agent_folders" ]; then
    echo "No agent folders found."
    exit 0
fi

echo "Found agent folders:"
echo "$agent_folders" | sed 's|.*/||' | sed 's|/$||'
echo ""

# Ask for confirmation
read -p "Do you want to clean up all agent folders? (y/N): " confirm

if [[ ! $confirm =~ ^[Yy]$ ]]; then
    echo "Operation cancelled."
    exit 0
fi

echo ""
echo "Cleaning up agent folders..."
echo "----------------------------"

# Remove all contents from each folder (including hidden files, but preserve .gitkeep)
for folder in $agent_folders; do
    folder_name=$(basename "$folder")
    echo "Removing all contents from: $folder_name"

    # Remove all files and directories except .gitkeep
    find "$folder" -mindepth 1 -not -name '.gitkeep' -delete 2>/dev/null

    echo "  ✓ Cleaned $folder_name (preserved .gitkeep)"
done

echo ""
echo "----------------------------"
echo "Cleanup complete!"
