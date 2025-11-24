#!/bin/bash

# Script to run AI coding agents with the benchmark prompt
# Each agent will be given the same prompt from benchmark-prompt.md

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$SCRIPT_DIR/.."
PROMPT_FILE="$WORKSPACE_DIR/benchmark-prompt.md"

# Check if prompt file exists
if [ ! -f "$PROMPT_FILE" ]; then
    echo "Error: benchmark-prompt.md not found at $PROMPT_FILE"
    exit 1
fi

# Read the prompt content - we'll pass it via stdin instead of command line to avoid escaping issues
PROMPT_CONTENT=$(cat "$PROMPT_FILE")

# Detect agent folders
COPILOT_DIR=$(ls -d "$WORKSPACE_DIR"/simple_sandbox_*copilot* 2>/dev/null | head -1)
CLAUDE_DIR=$(ls -d "$WORKSPACE_DIR"/simple_sandbox_*claude* 2>/dev/null | head -1)
CODEX_DIR=$(ls -d "$WORKSPACE_DIR"/simple_sandbox_codex 2>/dev/null | head -1)
GEMINI_DIR=$(ls -d "$WORKSPACE_DIR"/simple_sandbox_*gemini* 2>/dev/null | head -1)
OPENCODE_DIR=$(ls -d "$WORKSPACE_DIR"/simple_sandbox_*opencode* 2>/dev/null | head -1)

echo "AI Agent Benchmark Runner"
echo "=========================="
echo ""
echo "Using prompt from: $PROMPT_FILE"
echo ""

# Create logs directory with timestamp
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOGS_DIR="$WORKSPACE_DIR/benchmark_logs_$TIMESTAMP"
mkdir -p "$LOGS_DIR"

# Model configuration (can be overridden via environment variables)
COPILOT_MODEL="${COPILOT_MODEL:-gpt-5.1-codex}"
CLAUDE_MODEL="${CLAUDE_MODEL:-sonnet}"
CODEX_MODEL="${CODEX_MODEL:-gpt-5.1-codex}"
GEMINI_MODEL="${GEMINI_MODEL:-}"  # Uses default if not set
OPENCODE_MODEL="${OPENCODE_MODEL:-opencode/grok-code}"

echo "Model Configuration:"
echo "  Copilot: $COPILOT_MODEL"
echo "  Claude: $CLAUDE_MODEL"
echo "  Codex: $CODEX_MODEL"
[ -n "$GEMINI_MODEL" ] && echo "  Gemini: $GEMINI_MODEL" || echo "  Gemini: (default)"
echo "  OpenCode: $OPENCODE_MODEL"
echo ""
echo "To override models, set environment variables:"
echo "  COPILOT_MODEL=claude-haiku-4.5 CLAUDE_MODEL=opus ./scripts/run_benchmark.sh"
echo ""

# Function to run an agent
run_agent() {
    local agent_name=$1
    local agent_command=$2
    local agent_dir=$3
    local log_file=$4

    # Create a temporary file for the prompt to avoid shell escaping issues
    local temp_prompt=$(mktemp)
    echo "$PROMPT_CONTENT" > "$temp_prompt"

    # Store original command for display (before replacement)
    local display_command="${agent_command//__PROMPT_FILE__/<prompt from benchmark-prompt.md>}"

    # Replace __PROMPT_FILE__ placeholder in command with actual temp file path
    agent_command="${agent_command//__PROMPT_FILE__/$temp_prompt}"

    # If log file is provided, redirect all output to it
    if [ -n "$log_file" ]; then
        {
            echo "========================================="
            echo "Agent: $agent_name"
            echo "Time: $(date)"
            echo "========================================="
            echo ""
            echo "Directory: $agent_dir"
            echo "Command: $display_command"
            echo ""

            if [ -z "$agent_dir" ] || [ ! -d "$agent_dir" ]; then
                echo "✗ Directory not found for $agent_name"
                rm -f "$temp_prompt"
                return 1
            fi

            echo "----------------------------------------"
            echo "Output:"
            echo "----------------------------------------"

            # Change to agent directory and run command
            (cd "$agent_dir" && eval "$agent_command")
            local exit_code=$?

            echo ""
            echo "----------------------------------------"
            if [ $exit_code -eq 0 ]; then
                echo "✓ $agent_name completed successfully"
            else
                echo "✗ $agent_name failed with exit code: $exit_code"
            fi
            echo "========================================="

            rm -f "$temp_prompt"
            return $exit_code
        } &> "$log_file"
    else
        # Original behavior for non-logged runs (should rarely be used now)
        echo "----------------------------------------"
        echo "Running: $agent_name"
        echo "----------------------------------------"

        if [ -z "$agent_dir" ] || [ ! -d "$agent_dir" ]; then
            echo "✗ Directory not found for $agent_name"
            echo ""
            rm -f "$temp_prompt"
            return 1
        fi

        echo "Directory: $agent_dir"
        echo "Command: $display_command"
        echo ""

        # Change to agent directory and run command
        (cd "$agent_dir" && eval "$agent_command")
        local exit_code=$?

        if [ $exit_code -eq 0 ]; then
            echo "✓ $agent_name completed successfully"
        else
            echo "✗ $agent_name failed with exit code: $exit_code"
        fi
        echo ""

        rm -f "$temp_prompt"
        return $exit_code
    fi
}

# Run each agent with their specific CLI syntax
# Note: Some of these agents may not exist or have different CLI interfaces

echo "Select which agent to run:"
echo "1) GitHub Copilot"
echo "2) Claude"
echo "3) Codex"
echo "4) Gemini"
echo "5) OpenCode"
echo "6) All agents (sequential)"
echo "7) All agents (parallel)"
echo ""
read -p "Enter choice (1-7): " choice

case $choice in
    1)
        COPILOT_LOG="$LOGS_DIR/copilot.log"
        echo "Output will be saved to: $COPILOT_LOG"
        echo ""
        run_agent "GitHub Copilot" "copilot -p \"\$(cat __PROMPT_FILE__)\" --model $COPILOT_MODEL --allow-all-tools --allow-all-paths" "$COPILOT_DIR" "$COPILOT_LOG"
        echo ""
        echo "Log saved to: $COPILOT_LOG"
        ;;
    2)
        CLAUDE_LOG="$LOGS_DIR/claude.log"
        echo "Output will be saved to: $CLAUDE_LOG"
        echo ""
        run_agent "Claude" "claude --print --model $CLAUDE_MODEL --dangerously-skip-permissions \"\$(cat __PROMPT_FILE__)\"" "$CLAUDE_DIR" "$CLAUDE_LOG"
        echo ""
        echo "Log saved to: $CLAUDE_LOG"
        ;;
    3)
        CODEX_LOG="$LOGS_DIR/codex.log"
        echo "Output will be saved to: $CODEX_LOG"
        echo ""
        run_agent "Codex" "codex exec --model $CODEX_MODEL \"\$(cat __PROMPT_FILE__)\" --dangerously-bypass-approvals-and-sandbox" "$CODEX_DIR" "$CODEX_LOG"
        echo ""
        echo "Log saved to: $CODEX_LOG"
        ;;
    4)
        GEMINI_LOG="$LOGS_DIR/gemini.log"
        echo "Output will be saved to: $GEMINI_LOG"
        echo ""
        if [ -n "$GEMINI_MODEL" ]; then
            run_agent "Gemini" "gemini --model $GEMINI_MODEL \"\$(cat __PROMPT_FILE__)\" --yolo" "$GEMINI_DIR" "$GEMINI_LOG"
        else
            run_agent "Gemini" "gemini \"\$(cat __PROMPT_FILE__)\" --yolo" "$GEMINI_DIR" "$GEMINI_LOG"
        fi
        echo ""
        echo "Log saved to: $GEMINI_LOG"
        ;;
    5)
        OPENCODE_LOG="$LOGS_DIR/opencode.log"
        echo "Output will be saved to: $OPENCODE_LOG"
        echo ""
        run_agent "OpenCode" "opencode run --model $OPENCODE_MODEL \"\$(cat __PROMPT_FILE__)\"" "$OPENCODE_DIR" "$OPENCODE_LOG"
        echo ""
        echo "Log saved to: $OPENCODE_LOG"
        ;;
    6)
        echo "Output will be saved to: $LOGS_DIR"
        echo ""
        run_agent "GitHub Copilot" "copilot -p \"\$(cat __PROMPT_FILE__)\" --model $COPILOT_MODEL --allow-all-tools --allow-all-paths" "$COPILOT_DIR" "$LOGS_DIR/copilot.log"
        run_agent "Claude" "claude --print --model $CLAUDE_MODEL --dangerously-skip-permissions \"\$(cat __PROMPT_FILE__)\"" "$CLAUDE_DIR" "$LOGS_DIR/claude.log"
        run_agent "Codex" "codex exec --model $CODEX_MODEL \"\$(cat __PROMPT_FILE__)\" --dangerously-bypass-approvals-and-sandbox" "$CODEX_DIR" "$LOGS_DIR/codex.log"
        if [ -n "$GEMINI_MODEL" ]; then
            run_agent "Gemini" "gemini --model $GEMINI_MODEL \"\$(cat __PROMPT_FILE__)\" --yolo" "$GEMINI_DIR" "$LOGS_DIR/gemini.log"
        else
            run_agent "Gemini" "gemini \"\$(cat __PROMPT_FILE__)\" --yolo" "$GEMINI_DIR" "$LOGS_DIR/gemini.log"
        fi
        run_agent "OpenCode" "opencode run --model $OPENCODE_MODEL \"\$(cat __PROMPT_FILE__)\"" "$OPENCODE_DIR" "$LOGS_DIR/opencode.log"
        echo ""
        echo "All logs saved to: $LOGS_DIR"
        ;;
    7)
        echo ""
        echo "Running all agents in parallel..."
        echo "Output will be saved to: $LOGS_DIR"
        echo ""

        # Define log files
        COPILOT_LOG="$LOGS_DIR/copilot.log"
        CLAUDE_LOG="$LOGS_DIR/claude.log"
        CODEX_LOG="$LOGS_DIR/codex.log"
        GEMINI_LOG="$LOGS_DIR/gemini.log"
        OPENCODE_LOG="$LOGS_DIR/opencode.log"

        # Run all agents in parallel with output to log files
        run_agent "GitHub Copilot" "copilot -p \"\$(cat __PROMPT_FILE__)\" --model $COPILOT_MODEL --allow-all-tools --allow-all-paths" "$COPILOT_DIR" "$COPILOT_LOG" &
        COPILOT_PID=$!

        run_agent "Claude" "claude --print --model $CLAUDE_MODEL --dangerously-skip-permissions \"\$(cat __PROMPT_FILE__)\"" "$CLAUDE_DIR" "$CLAUDE_LOG" &
        CLAUDE_PID=$!

        run_agent "Codex" "codex exec --model $CODEX_MODEL \"\$(cat __PROMPT_FILE__)\" --dangerously-bypass-approvals-and-sandbox" "$CODEX_DIR" "$CODEX_LOG" &
        CODEX_PID=$!

        if [ -n "$GEMINI_MODEL" ]; then
            run_agent "Gemini" "gemini --model $GEMINI_MODEL \"\$(cat __PROMPT_FILE__)\" --yolo" "$GEMINI_DIR" "$GEMINI_LOG" &
        else
            run_agent "Gemini" "gemini \"\$(cat __PROMPT_FILE__)\" --yolo" "$GEMINI_DIR" "$GEMINI_LOG" &
        fi
        GEMINI_PID=$!

        run_agent "OpenCode" "opencode run --model $OPENCODE_MODEL \"\$(cat __PROMPT_FILE__)\"" "$OPENCODE_DIR" "$OPENCODE_LOG" &
        OPENCODE_PID=$!

        # Wait for all background processes and capture their exit codes
        echo "Waiting for all agents to complete..."
        echo ""

        wait $COPILOT_PID
        COPILOT_EXIT=$?

        wait $CLAUDE_PID
        CLAUDE_EXIT=$?

        wait $CODEX_PID
        CODEX_EXIT=$?

        wait $GEMINI_PID
        GEMINI_EXIT=$?

        wait $OPENCODE_PID
        OPENCODE_EXIT=$?

        # Display summary
        echo "========================================="
        echo "Parallel Execution Summary"
        echo "========================================="
        echo ""

        [ $COPILOT_EXIT -eq 0 ] && echo "✓ GitHub Copilot completed successfully" || echo "✗ GitHub Copilot failed (exit code: $COPILOT_EXIT)"
        echo "  Log: $COPILOT_LOG"
        echo ""

        [ $CLAUDE_EXIT -eq 0 ] && echo "✓ Claude completed successfully" || echo "✗ Claude failed (exit code: $CLAUDE_EXIT)"
        echo "  Log: $CLAUDE_LOG"
        echo ""

        [ $CODEX_EXIT -eq 0 ] && echo "✓ Codex completed successfully" || echo "✗ Codex failed (exit code: $CODEX_EXIT)"
        echo "  Log: $CODEX_LOG"
        echo ""

        [ $GEMINI_EXIT -eq 0 ] && echo "✓ Gemini completed successfully" || echo "✗ Gemini failed (exit code: $GEMINI_EXIT)"
        echo "  Log: $GEMINI_LOG"
        echo ""

        [ $OPENCODE_EXIT -eq 0 ] && echo "✓ OpenCode completed successfully" || echo "✗ OpenCode failed (exit code: $OPENCODE_EXIT)"
        echo "  Log: $OPENCODE_LOG"
        echo ""
        ;;
    *)
        echo "Invalid choice"
        exit 1
        ;;
esac

echo "=========================================="
echo "Benchmark run complete"
echo "=========================================="
