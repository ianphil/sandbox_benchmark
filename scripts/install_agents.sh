#!/bin/bash

# Script to install AI coding agents
# This installs various AI assistant CLI tools globally via npm

echo "Installing AI Coding Agents..."
echo "==============================="

# Array of agents to install
agents=(
    "@github/copilot"
    "@anthropic-ai/claude-code"
    "@openai/codex"
    "@google/gemini-cli"
    "opencode-ai"
)

# Track installation status
failed=()
succeeded=()

# Install each agent
for agent in "${agents[@]}"; do
    echo ""
    echo "Installing $agent..."
    if npm install -g "$agent"; then
        succeeded+=("$agent")
        echo "✓ $agent installed successfully"
    else
        failed+=("$agent")
        echo "✗ Failed to install $agent"
    fi
done

# Summary
echo ""
echo "==============================="
echo "Installation Summary"
echo "==============================="

if [ ${#succeeded[@]} -gt 0 ]; then
    echo "Successfully installed (${#succeeded[@]}):"
    for agent in "${succeeded[@]}"; do
        echo "  ✓ $agent"
    done
fi

if [ ${#failed[@]} -gt 0 ]; then
    echo ""
    echo "Failed to install (${#failed[@]}):"
    for agent in "${failed[@]}"; do
        echo "  ✗ $agent"
    done
    exit 1
fi

echo ""
echo "All agents installed successfully!"
