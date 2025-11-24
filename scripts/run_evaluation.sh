#!/bin/bash

# Script to run LLM-as-a-judge evaluation on AI agent outputs
# Uses Claude (via codex) to evaluate each agent's implementation

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$SCRIPT_DIR/.."
EVALUATION_PROMPT="$WORKSPACE_DIR/evaluation-prompt.md"
EVALUATION_TEMPLATE="$WORKSPACE_DIR/evaluation-template.md"
BENCHMARK_PROMPT="$WORKSPACE_DIR/benchmark-prompt.md"

# Check if required files exist
if [ ! -f "$EVALUATION_PROMPT" ]; then
    echo "Error: evaluation-prompt.md not found at $EVALUATION_PROMPT"
    exit 1
fi

if [ ! -f "$EVALUATION_TEMPLATE" ]; then
    echo "Error: evaluation-template.md not found at $EVALUATION_TEMPLATE"
    exit 1
fi

if [ ! -f "$BENCHMARK_PROMPT" ]; then
    echo "Error: benchmark-prompt.md not found at $BENCHMARK_PROMPT"
    exit 1
fi

# Create evaluations directory with timestamp
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
EVAL_DIR="$WORKSPACE_DIR/evaluations_$TIMESTAMP"
mkdir -p "$EVAL_DIR"

echo "AI Agent Evaluation Runner (LLM-as-a-Judge)"
echo "==========================================="
echo ""
echo "Using evaluation prompt: $EVALUATION_PROMPT"
echo "Results will be saved to: $EVAL_DIR"
echo ""

# Detect sandbox directories
SANDBOX_DIRS=($(find "$WORKSPACE_DIR" -maxdepth 1 -type d -name "simple_sandbox_*" | sort))

if [ ${#SANDBOX_DIRS[@]} -eq 0 ]; then
    echo "Error: No simple_sandbox_* directories found"
    exit 1
fi

echo "Found ${#SANDBOX_DIRS[@]} implementations to evaluate:"
for dir in "${SANDBOX_DIRS[@]}"; do
    echo "  - $(basename "$dir")"
done
echo ""

# Function to evaluate a single implementation
evaluate_implementation() {
    local sandbox_dir=$1
    local sandbox_name=$(basename "$sandbox_dir")
    local eval_output="$EVAL_DIR/${sandbox_name}_evaluation.md"

    echo "========================================="
    echo "Evaluating: $sandbox_name"
    echo "========================================="
    echo ""

    if [ ! -d "$sandbox_dir" ] || [ -z "$(ls -A "$sandbox_dir" 2>/dev/null | grep -v '\.gitkeep')" ]; then
        echo "✗ Directory is empty or does not exist"
        echo ""
        echo "# Evaluation: $sandbox_name" > "$eval_output"
        echo "" >> "$eval_output"
        echo "**Status:** SKIPPED - Directory is empty or does not exist" >> "$eval_output"
        echo "" >> "$eval_output"
        echo "**Score:** 0/100" >> "$eval_output"
        return 1
    fi

    echo "Directory: $sandbox_dir"
    echo "Output file: $eval_output"
    echo ""

    # Create evaluation prompt for Claude
    local judge_prompt=$(cat <<EOF
You are an expert code reviewer conducting an objective evaluation of an AI coding agent's implementation.

# Context

An AI coding agent was given the following task:

$(cat "$BENCHMARK_PROMPT")

The agent's implementation is located in: $sandbox_dir

# Your Task

Using the evaluation criteria and instructions from the evaluation prompt below, thoroughly review the implementation and provide a complete scored evaluation.

$(cat "$EVALUATION_PROMPT")

# Instructions

1. Navigate to the implementation directory: $sandbox_dir
2. Read all source files to understand the implementation
3. Check for the presence of required files (pyproject.toml, .http file, etc.)
4. Analyze the code against each criterion in the evaluation checklist
5. Assign points objectively based on what is actually implemented
6. Fill out the complete evaluation template with:
   - All checkboxes marked appropriately
   - Points assigned for each criterion
   - Notes for each major category
   - Final scoring summary table
   - Overall assessment with strengths and weaknesses

# Output Format

Provide your evaluation in markdown format following the structure in evaluation-prompt.md. Be thorough, objective, and specific in your assessment. Include code snippets where relevant to justify your scoring decisions.

Start your evaluation now for: $sandbox_name
EOF
)

    # Run Claude (via codex) to evaluate the implementation
    echo "Running LLM judge evaluation..."
    echo ""

    # Save the evaluation using codex/claude
    (cd "$sandbox_dir" && echo "$judge_prompt" | claude --print --dangerously-skip-permissions) > "$eval_output" 2>&1
    local exit_code=$?

    if [ $exit_code -eq 0 ]; then
        echo "✓ Evaluation completed successfully"
        echo "  Report saved to: $eval_output"
    else
        echo "✗ Evaluation failed with exit code: $exit_code"
        echo "  Partial output may be in: $eval_output"
    fi
    echo ""

    return $exit_code
}

# Ask user for evaluation mode
echo "Select evaluation mode:"
echo "1) Evaluate specific implementation"
echo "2) Evaluate all implementations (sequential)"
echo "3) Evaluate all implementations (parallel)"
echo ""
read -p "Enter choice (1-3): " choice

case $choice in
    1)
        # Show numbered list of implementations
        echo ""
        echo "Available implementations:"
        for i in "${!SANDBOX_DIRS[@]}"; do
            echo "$((i+1))) $(basename "${SANDBOX_DIRS[$i]}")"
        done
        echo ""
        read -p "Enter number (1-${#SANDBOX_DIRS[@]}): " impl_choice

        if [ "$impl_choice" -ge 1 ] && [ "$impl_choice" -le "${#SANDBOX_DIRS[@]}" ]; then
            selected_dir="${SANDBOX_DIRS[$((impl_choice-1))]}"
            evaluate_implementation "$selected_dir"
        else
            echo "Invalid choice"
            exit 1
        fi
        ;;
    2)
        # Sequential evaluation
        echo ""
        echo "Starting sequential evaluation of all implementations..."
        echo ""

        success_count=0
        fail_count=0

        for sandbox_dir in "${SANDBOX_DIRS[@]}"; do
            evaluate_implementation "$sandbox_dir"
            if [ $? -eq 0 ]; then
                ((success_count++))
            else
                ((fail_count++))
            fi
        done

        echo "========================================="
        echo "Sequential Evaluation Complete"
        echo "========================================="
        echo ""
        echo "✓ Successful evaluations: $success_count"
        echo "✗ Failed evaluations: $fail_count"
        echo ""
        echo "All evaluation reports saved to: $EVAL_DIR"
        ;;
    3)
        # Parallel evaluation
        echo ""
        echo "Running all evaluations in parallel..."
        echo "Output will be saved to: $EVAL_DIR"
        echo ""

        # Store PIDs and names
        declare -A EVAL_PIDS

        # Launch all evaluations in parallel
        for sandbox_dir in "${SANDBOX_DIRS[@]}"; do
            sandbox_name=$(basename "$sandbox_dir")
            evaluate_implementation "$sandbox_dir" &
            EVAL_PIDS[$sandbox_name]=$!
        done

        echo "Waiting for all evaluations to complete..."
        echo ""

        # Wait for all evaluations and collect exit codes
        declare -A EXIT_CODES
        for sandbox_name in "${!EVAL_PIDS[@]}"; do
            wait ${EVAL_PIDS[$sandbox_name]}
            EXIT_CODES[$sandbox_name]=$?
        done

        # Display summary
        echo "========================================="
        echo "Parallel Evaluation Summary"
        echo "========================================="
        echo ""

        success_count=0
        fail_count=0

        for sandbox_name in "${!EXIT_CODES[@]}"; do
            if [ ${EXIT_CODES[$sandbox_name]} -eq 0 ]; then
                echo "✓ $sandbox_name - Evaluation completed"
                ((success_count++))
            else
                echo "✗ $sandbox_name - Evaluation failed (exit code: ${EXIT_CODES[$sandbox_name]})"
                ((fail_count++))
            fi
            echo "  Report: $EVAL_DIR/${sandbox_name}_evaluation.md"
            echo ""
        done

        echo "Successful evaluations: $success_count"
        echo "Failed evaluations: $fail_count"
        echo ""
        ;;
    *)
        echo "Invalid choice"
        exit 1
        ;;
esac

echo "========================================="
echo "Evaluation run complete"
echo "========================================="
echo ""
echo "All evaluation reports are available in:"
echo "  $EVAL_DIR"
echo ""
echo "To view a specific evaluation:"
echo "  cat $EVAL_DIR/<agent_name>_evaluation.md"
echo ""
echo "To compare all scores, review the scoring summary tables in each evaluation file."
echo ""
